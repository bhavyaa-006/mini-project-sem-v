from urllib.parse import urlparse
from urllib.robotparser import RobotFileParser

from safescan_engines.config import settings


_robots_cache: dict[str, RobotFileParser] = {}


def can_fetch_url(url: str, user_agent: str = settings.off_user_agent) -> bool:
    parsed = urlparse(url)
    if parsed.scheme not in ("http", "https") or not parsed.netloc:
        return False
    origin = f"{parsed.scheme}://{parsed.netloc}"
    robots = _robots_cache.get(origin)
    if robots is None:
        robots = RobotFileParser(f"{origin}/robots.txt")
        try:
            robots.read()
        except Exception:
            _robots_cache[origin] = robots
            return False
        _robots_cache[origin] = robots
    try:
        return robots.can_fetch(user_agent, url)
    except Exception:
        return False