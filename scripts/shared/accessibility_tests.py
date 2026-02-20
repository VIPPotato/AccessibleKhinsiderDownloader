#!/usr/bin/env python3
"""Static accessibility checks for QML UI files.

This suite enforces a baseline of screen-reader semantics and keyboard parity
for every major feature panel.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _require_contains(content: str, needle: str, rel_path: str, errors: list[str]) -> None:
    if needle not in content:
        errors.append(f"{rel_path}: missing required snippet `{needle}`")


def _run_feature_checks(repo_root: Path) -> list[str]:
    errors: list[str] = []

    feature_specs: dict[str, dict[str, list[str]]] = {
        "navigation": {
            "src/ui/Main.qml": [
                "Accessible.role: Accessible.Pane",
                "Accessible.name: \"Khinsider Downloader\"",
                "setActiveTab(",
                "Keys.onPressed",
            ],
            "src/ui/shared/SideButton.qml": [
                "Accessible.role: Accessible.Button",
                "Accessible.name: accessibleName",
                "Accessible.description: accessibleDescription",
                "Keys.onReturnPressed",
                "Keys.onEnterPressed",
                "Keys.onSpacePressed",
            ],
        },
        "search": {
            "src/ui/search/SearchPanel.qml": [
                "Accessible.role: Accessible.Pane",
                "Accessible.name: \"Search panel\"",
                "Accessible.role: Accessible.EditableText",
                "Accessible.name: \"Search albums\"",
                "Qt.Key_Tab",
                "Qt.Key_Backtab",
                "accessibleName: \"Add checked albums to downloads\"",
                "accessibleName: \"Append checked album URLs to download input\"",
                "Qt.Key_D",
                "Qt.Key_U",
            ],
            "src/ui/search/SearchResultsList.qml": [
                "Accessible.role: Accessible.List",
                "Accessible.role: Accessible.ListItem",
                "Accessible.selected: isSelected",
                "Accessible.checkable: true",
                "Accessible.checked: isChecked",
                "activeFocusOnTab: false",
                "Keys.onUpPressed",
                "Keys.onDownPressed",
                "toggleResultChecked(",
                "addCheckedToDownloads()",
                "appendCheckedUrlsToDownloadInput()",
                "model.albumLink",
            ],
            "src/ui/search/AlbumInfoSide.qml": [
                "Accessible.role: Accessible.Pane",
                "Accessible.name: \"Selected album details\"",
            ],
            "src/ui/search/AlbumImageCaret.qml": [
                "Accessible.role: Accessible.Pane",
                "Accessible.name: \"Album artwork viewer\"",
                "Keys.onLeftPressed",
                "Keys.onRightPressed",
            ],
            "src/ui/search/AlbumImageCaretButton.qml": [
                "Accessible.role: Accessible.Button",
                "Keys.onReturnPressed",
                "Keys.onEnterPressed",
                "Keys.onSpacePressed",
            ],
        },
        "download": {
            "src/ui/download/DownloadPanel.qml": [
                "Accessible.role: Accessible.Pane",
                "Accessible.name: \"Download panel\"",
                "Accessible.name: \"Album URLs input\"",
                "downloaderVM.bulkUrlBuffer",
                "accessibleName: \"Import URLs into download queue\"",
                "accessibleName: \"Cancel all downloads\"",
                "Qt.Key_Tab",
                "Qt.Key_Backtab",
            ],
            "src/ui/download/DownloadSide.qml": [
                "Accessible.role: Accessible.Pane",
                "Accessible.name: \"Download queue panel\"",
                "Accessible.role: Accessible.List",
            ],
            "src/ui/download/AlbumItem.qml": [
                "Accessible.role: Accessible.ListItem",
                "Accessible.name: \"Retry album download\"",
                "Accessible.name: \"Cancel album download\"",
                "Keys.onPressed",
                "Qt.Key_Delete",
                "Qt.Key_R",
            ],
        },
        "settings": {
            "src/ui/settings/SettingsPanel.qml": [
                "Accessible.role: Accessible.Pane",
                "Accessible.name: \"Settings panel\"",
                "accessibleName: \"Select download path\"",
                "accessibleName: \"Enable logging\"",
                "accessibleName: \"Download threads\"",
                "accessibleName: \"Check for updates\"",
            ],
            "src/ui/shared/WEnumButton.qml": [
                "Accessible.role: Accessible.ComboBox",
                "Accessible.valueChanged()",
                "Accessible.name: announceValueOnly ? buttonlabel.text : (accessibleName + \": \" + buttonlabel.text)",
                "Keys.onUpPressed",
                "Keys.onDownPressed",
                "Keys.onLeftPressed",
                "Keys.onRightPressed",
            ],
            "src/ui/shared/WNumberBox.qml": [
                "Accessible.role: Accessible.SpinBox",
                "Accessible.valueChanged()",
                "Accessible.name: accessibleName + \" \" + currentNumber",
                "Keys.onUpPressed",
                "Keys.onDownPressed",
                "Keys.onPressed",
                "Qt.Key_Home",
                "Qt.Key_End",
            ],
        },
        "about": {
            "src/ui/about/AboutPanel.qml": [
                "Accessible.role: Accessible.Pane",
                "Accessible.name: \"About panel\"",
                "Accessible.role: Accessible.List",
                "Accessible.role: Accessible.ListItem",
                "activeFocusOnTab: true",
                "contributorsListScope.focusContributor(",
                "Accessible.selected: isSelected",
                "Accessible.role: Accessible.Link",
            ],
            "src/ui/about/UpdateCheckerDialog.qml": [
                "title: \"A new update has been released!\"",
                "Accessible.role: Accessible.StaticText",
                "accessibleName: \"Open downloads page\"",
                "Keys.onEscapePressed",
            ],
        },
        "shared-controls": {
            "src/ui/shared/WButton.qml": [
                "Accessible.role: Accessible.Button",
                "Keys.onReturnPressed",
                "Keys.onEnterPressed",
                "Keys.onSpacePressed",
            ],
        },
    }

    for _, file_map in feature_specs.items():
        for rel_path, needles in file_map.items():
            path = repo_root / rel_path
            if not path.exists():
                errors.append(f"{rel_path}: file is missing")
                continue
            content = _read(path)
            for needle in needles:
                _require_contains(content, needle, rel_path, errors)

    return errors


def _run_generic_checks(repo_root: Path) -> list[str]:
    errors: list[str] = []
    ui_root = repo_root / "src" / "ui"
    if not ui_root.exists():
        return ["src/ui: directory is missing"]

    allow_missing_accessibility = {
        "src/ui/shared/WScrollView.qml",
    }
    allow_mouse_without_keyboard = {
        "src/ui/shared/WNumberBoxButton.qml",
    }
    keyboard_markers = (
        "Keys.onReturnPressed",
        "Keys.onEnterPressed",
        "Keys.onSpacePressed",
        "Keys.onUpPressed",
        "Keys.onDownPressed",
        "Keys.onLeftPressed",
        "Keys.onRightPressed",
        "Keys.onHomePressed",
        "Keys.onEndPressed",
        "Keys.onPressed",
    )

    for qml_path in sorted(ui_root.rglob("*.qml")):
        rel_path = qml_path.relative_to(repo_root).as_posix()
        content = _read(qml_path)

        if rel_path not in allow_missing_accessibility and "Accessible." not in content:
            errors.append(f"{rel_path}: expected at least one `Accessible.*` property")

        if "MouseArea" in content and rel_path not in allow_mouse_without_keyboard:
            if not any(marker in content for marker in keyboard_markers):
                errors.append(
                    f"{rel_path}: has MouseArea but no keyboard handling (Keys.on*)."
                )

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Run QML accessibility checks")
    parser.add_argument(
        "--repo-root",
        default=".",
        help="Repository root path (default: current directory)",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()

    failures = []
    failures.extend(_run_feature_checks(repo_root))
    failures.extend(_run_generic_checks(repo_root))

    if failures:
        print("Accessibility checks failed:")
        for failure in failures:
            print(f" - {failure}")
        return 1

    print("Accessibility checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
