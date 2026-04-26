import ralph


def test_format_duration_basic():
    assert ralph.format_duration(0.0) == "0s"


def test_format_duration_hour_plus_ends_with_s():
    assert ralph.format_duration(3725.0).endswith("s")
