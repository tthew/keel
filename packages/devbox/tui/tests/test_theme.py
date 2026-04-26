from tui.theme import theme


def test_theme_neutral_500():
    assert theme.colors.neutral_500 == "oklch(52% 0 0)"
