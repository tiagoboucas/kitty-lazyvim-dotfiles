# Custom kitty tab bar: powerline (slanted) style + a clickable close "✕" icon.
#
# kitty's built-in tab-bar mouse handling is hardcoded (left-click = activate,
# middle-click = close) and a custom draw_tab cannot register click regions.
# So this module ALSO monkeypatches TabManager.handle_tab_bar_mouse to make a
# left-click on the drawn ✕ close that tab. We record the cell each tab's ✕
# occupies while drawing, and consult that map when a click arrives.
#
# Enabled via `tab_bar_style custom` in kitty.conf.

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
_close_cells: 'dict[int, tuple[int, int]]' = {}


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


# --- Make the ✕ clickable: patch the (otherwise hardcoded) mouse handler. -----

def _install_close_click_handler() -> None:
    from kitty.tabs import TabManager, set_tab_being_dragged, get_boss
    from kitty.fast_data_types import GLFW_MOUSE_BUTTON_LEFT, GLFW_PRESS, GLFW_RELEASE

    if getattr(TabManager.handle_tab_bar_mouse, '_close_icon_patched', False):
        return
    _orig = TabManager.handle_tab_bar_mouse

    def handle_tab_bar_mouse(self, x, y, button, modifiers, action):
        if button == GLFW_MOUSE_BUTTON_LEFT and action in (GLFW_PRESS, GLFW_RELEASE):
            try:
                tb = self.tab_bar
                g = getattr(tb, 'window_geometry', None)
                if getattr(tb, 'laid_out_once', False) and g is not None:
                    # Same pixel->cell mapping kitty's own tab_id_at uses.
                    cell_x = int((x - g.left) // (tb.cell_width or 1))
                    tab_id = tb.tab_id_at(x, y)  # NB: takes BOTH x and y
                    rng = _close_cells.get(tab_id)
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

    handle_tab_bar_mouse._close_icon_patched = True
    TabManager.handle_tab_bar_mouse = handle_tab_bar_mouse


_install_close_click_handler()
