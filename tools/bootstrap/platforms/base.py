from abc import ABC, abstractmethod
from dataclasses import dataclass

from tools.bootstrap.packages.linux import PackageGroup


@dataclass(frozen=True)
class DetectedPlatform:
    platform_id: str
    id_like: tuple[str, ...]


class PlatformAdapter(ABC):
    family: str

    @abstractmethod
    def matches(self, platform: DetectedPlatform) -> bool:
        raise NotImplementedError

    @abstractmethod
    def install_dependencies_command(
        self,
        package_group: PackageGroup,
        assume_yes: bool,
    ) -> list[str]:
        raise NotImplementedError
