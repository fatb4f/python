"""Validate the contract model, without exercising host security controls."""

from pathlib import Path
import shutil
import subprocess

import pytest


SPECIMEN = Path(__file__).resolve().parents[2] / "specimens" / "workstation-security"
SCHEMA = ("identity.cue", "authority.cue", "assets.cue", "recovery.cue")
CUE = shutil.which("cue")


@pytest.mark.skipif(CUE is None, reason="CUE is required for contract validation")
@pytest.mark.parametrize(
    ("fixture", "definition", "expected_error"),
    [
        ("baseline.json", "#Contract", None),
        ("command-grant.json", "#CommandGrant", None),
        ("undeclared-transition.json", "#Authority", "interactiveGrants"),
        ("undeclared-command.json", "#Authority", "commandGrants"),
        ("disguised-shell.json", "#CommandGrant", "executable"),
        ("asset-modification.json", "#ProtectedAsset", "workloadMayModify"),
        ("no-recovery.json", "#Recovery", "provisioningAllowed"),
    ],
)
def test_contract_fixtures(fixture, definition, expected_error):
    result = subprocess.run(
        [CUE, "vet", "-c", *SCHEMA, f"fixtures/{fixture}", "-d", definition],
        cwd=SPECIMEN,
        capture_output=True,
        text=True,
        check=False,
    )
    if expected_error is None:
        assert result.returncode == 0, result.stderr
    else:
        assert result.returncode != 0, fixture
        assert expected_error in result.stderr, result.stderr
