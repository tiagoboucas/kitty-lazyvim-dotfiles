# Custom kitty tab bar: powerline (slanted) style + a clickable close "✕" icon,
# with tab drag-and-drop fixed so it ALWAYS reorders and never accidentally
# detaches the tab into a new OS window.
#
# Three patches (kitty 0.47.x):
#  1. draw_tab             — powerline look + "✕" per tab (records its cells).
#  2. handle_tab_bar_mouse — left-click on the "✕" closes that tab.
#  3. Boss.on_drop / on_drag_source_finished — dropping a dragged tab outside
#     the (one-cell-tall) tab bar used to detach it into a new OS window.
#     Now the drop coordinates are clamped into the tab bar, so releasing
#     slightly off the bar still just reorders. Dragging out of the kitty
#     window entirely is a no-op instead of a detach.
#
# Enabled via `tab_bar_style custom` in kitty.conf.

import os

from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_title,
    powerline_symbols,
)
from kitty.fast_data_types import Screen

CLOSE_GLYPH = '✕'

# tab_id -> (first_cell, last_cell) that the "✕" (and its leading space) occupy.
# IMPORTANT: kitty loads this file with runpy.run_path, which re-executes it
# with FRESH globals on every config reload — but the mouse-handler patch is
# only installed once and closes over the dict from the first run. Anchor the
# registry on the stable kitty.tab_bar module so every re-execution (and the
# originally installed handler) share the same dict.
import kitty.tab_bar as _ktb

_close_cells: 'dict[int, tuple[int, int]]' = getattr(_ktb, '_custom_close_cells', None) or {}
_ktb._custom_close_cells = _close_cells


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    tab_bg = screen.cursor.bg
    tab_fg = screen.cursor.fg
    default_bg = as_rgb(int(draw_data.default_bg))
    if extra_data.next_tab:
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = default_bg
        needs_soft_separator = False

    separator_symbol, soft_separator_symbol = powerline_symbols.get(
        draw_data.powerline_style, ('', ''))
    # room for: title + " ✕" + separator
    min_title_length = 1 + 2
    start_draw = 2

    if screen.cursor.x == 0:
        screen.cursor.bg = tab_bg
        screen.draw(' ')
        start_draw = 1

    screen.cursor.bg = tab_bg
    if min_title_length >= max_tab_length:
        screen.draw('…')
    else:
        draw_title(draw_data, screen, tab, index, max_tab_length)
        extra = screen.cursor.x + start_draw - before - max_tab_length
        if extra > 0 and extra + 1 < screen.cursor.x:
            screen.cursor.x -= extra + 1
            screen.draw('…')

    # Close icon, drawn in a muted grey so it reads as a subtle button.
    # Record the cells it occupies (leading space + glyph) so a click here closes.
    close_start = screen.cursor.x
    screen.cursor.fg = as_rgb(0x808080)
    screen.draw(f' {CLOSE_GLYPH}')
    _close_cells[tab.tab_id] = (close_start, screen.cursor.x - 1)
    screen.cursor.fg = tab_fg

    if not needs_soft_separator:
        screen.draw(' ')
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
        screen.draw(separator_symbol)
    else:
        prev_fg = screen.cursor.fg
        if tab_bg == tab_fg:
            screen.cursor.fg = default_bg
        elif tab_bg != default_bg:
            c1 = draw_data.inactive_bg.contrast(draw_data.default_bg)
            c2 = draw_data.inactive_bg.contrast(draw_data.inactive_fg)
            if c1 < c2:
                screen.cursor.fg = default_bg
        screen.draw(f' {soft_separator_symbol}')
        screen.cursor.fg = prev_fg

    end = screen.cursor.x
    if end < screen.columns:
        screen.draw(' ')
    return end


# --- Patch 2: make the ✕ clickable ------------------------------------------

def _install_close_click_handler() -> None:
    from kitty.tabs import TabManager, set_tab_being_dragged, get_boss
    from kitty.fast_data_types import GLFW_MOUSE_BUTTON_LEFT, GLFW_PRESS, GLFW_RELEASE

    # Anchor the pristine original on the class so re-running this file (kitty
    # re-executes it on every config reload) reinstalls a fresh handler without
    # ever stacking wrappers.
    _orig = getattr(TabManager, '_close_icon_orig_handler', None)
    if _orig is None:
        _orig = TabManager.handle_tab_bar_mouse
        TabManager._close_icon_orig_handler = _orig

    def handle_tab_bar_mouse(self, x, y, button, modifiers, action):
        if button == GLFW_MOUSE_BUTTON_LEFT and action in (GLFW_PRESS, GLFW_RELEASE):
            try:
                tb = self.tab_bar
                g = getattr(tb, 'window_geometry', None)
                if getattr(tb, 'laid_out_once', False) and g is not None:
                    # Same pixel->cell mapping kitty's own tab_id_at uses.
                    cell_x = int((x - g.left) // (tb.cell_width or 1))
                    tab_id = tb.tab_id_at(int(x))
                    # Look the registry up at call time (never a stale closure).
                    rng = getattr(_ktb, '_custom_close_cells', {}).get(tab_id)
                    if tab_id > 0 and rng and rng[0] <= cell_x <= rng[1]:
                        # Consume both press and release over the ✕ so it never
                        # activates or starts a drag; close on release.
                        if action == GLFW_RELEASE:
                            tab = self.tab_for_id(tab_id)
                            if tab is not None:
                                set_tab_being_dragged()
                                get_boss().close_tab(tab)
                        return
            except Exception:
                pass  # fall through to default handling on any surprise
        return _orig(self, x, y, button, modifiers, action)

    TabManager.handle_tab_bar_mouse = handle_tab_bar_mouse


# --- Patch 3: drag a tab = reorder only, never detach ------------------------

def _install_drag_fixes() -> None:
    from kitty.boss import Boss
    from kitty.tabs import get_tab_being_dragged, set_tab_being_dragged

    _tab_mime = f'application/net.kovidgoyal.kitty-tab-{os.getpid()}'

    if not getattr(Boss.on_drop, '_tab_drag_patched', False):
        _orig_on_drop = Boss.on_drop

        def on_drop(self, os_window_id, drop, from_self, x, y):
            # If a kitty tab is being dropped, clamp the drop point into the
            # tab bar so kitty reorders instead of detaching to a new window.
            try:
                if not isinstance(drop, int) and _tab_mime in drop:
                    from kitty.fast_data_types import viewport_for_window
                    tab_bar = viewport_for_window(os_window_id)[1]
                    if tab_bar.bottom > tab_bar.top and tab_bar.right > tab_bar.left:
                        x = min(max(x, tab_bar.left), tab_bar.right - 1)
                        y = min(max(y, tab_bar.top), tab_bar.bottom - 1)
            except Exception:
                pass
            return _orig_on_drop(self, os_window_id, drop, from_self, x, y)

        on_drop._tab_drag_patched = True
        Boss.on_drop = on_drop

    if not getattr(Boss.on_drag_source_finished, '_tab_drag_patched', False):
        _orig_finished = Boss.on_drag_source_finished

        def on_drag_source_finished(self, was_dropped, was_canceled, accepted_mime_type,
                                    action, data, needs_toplevel_on_wayland):
            # Tab drag ended outside any kitty window: clean up, do NOT detach.
            try:
                tab_id = int((data or {}).get(_tab_mime, b'0').decode())
                if tab_id and get_tab_being_dragged()[0] == tab_id:
                    set_tab_being_dragged()
                    for tm in self.all_tab_managers:
                        tm.on_tab_drop_move()
                        tm.layout_tab_bar()
                    return
            except Exception:
                pass
            return _orig_finished(self, was_dropped, was_canceled, accepted_mime_type,
                                  action, data, needs_toplevel_on_wayland)

        on_drag_source_finished._tab_drag_patched = True
        Boss.on_drag_source_finished = on_drag_source_finished


_install_close_click_handler()
_install_drag_fixes()
