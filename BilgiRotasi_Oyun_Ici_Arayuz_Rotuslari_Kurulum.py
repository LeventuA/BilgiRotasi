#!/usr/bin/env python3
from pathlib import Path
import base64
import re
import shutil
import subprocess
import tempfile

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
TEST = Path("test/system_smoke_test.dart")
TARGET = Path("lib/game_ui_polish.dart")

POLISH_B64 = """cGFydCBvZiAnbWFpbi5kYXJ0JzsKCmNsYXNzIEdhbWVVaU1ldHJpY3MgewogIEdhbWVVaU1ldHJpY3MuXygpOwoKICBzdGF0aWMgY29uc3QgZG91YmxlIHdpZGVCcmVha3BvaW50ID0gNzYwOwogIHN0YXRpYyBjb25zdCBkb3VibGUgbWF4aW11bUJvYXJkU2l6ZSA9IDcyMDsKCiAgc3RhdGljIGJvb2wgaXNDb21wYWN0KGRvdWJsZSB3aWR0aCkgPT4gd2lkdGggPCB3aWRlQnJlYWtwb2ludDsKCiAgc3RhdGljIGRvdWJsZSBib2FyZFNpemUoZG91YmxlIGF2YWlsYWJsZVdpZHRoKSB7CiAgICBpZiAoYXZhaWxhYmxlV2lkdGggPD0gMCkgcmV0dXJuIDA7CiAgICByZXR1cm4gbWluKGF2YWlsYWJsZVdpZHRoLCBtYXhpbXVtQm9hcmRTaXplKTsKICB9CgogIHN0YXRpYyBTdHJpbmcgYWN0aW9uTGFiZWwoewogICAgcmVxdWlyZWQgYm9vbCBidXN5LAogICAgcmVxdWlyZWQgYm9vbCBoYXNBbGxCYWRnZXMsCiAgfSkgewogICAgaWYgKGJ1c3kpIHJldHVybiAnQmVrbGXigKYnOwogICAgcmV0dXJuIGhhc0FsbEJhZGdlcyA/ICdGaW5hbCBTb3J1c3VuYSBHZcOnJyA6ICdaYXLEsSBBdCc7CiAgfQoKICBzdGF0aWMgSWNvbkRhdGEgYWN0aW9uSWNvbih7CiAgICByZXF1aXJlZCBib29sIGJ1c3ksCiAgICByZXF1aXJlZCBib29sIGhhc0FsbEJhZGdlcywKICB9KSB7CiAgICBpZiAoYnVzeSkgcmV0dXJuIEljb25zLmhvdXJnbGFzc190b3Bfcm91bmRlZDsKICAgIHJldHVybiBoYXNBbGxCYWRnZXMKICAgICAgICA/IEljb25zLmVtb2ppX2V2ZW50c19yb3VuZGVkCiAgICAgICAgOiBJY29ucy5jYXNpbm9fcm91bmRlZDsKICB9Cn0KCmNsYXNzIEdhbWVNb2JpbGVBY3Rpb25CYXIgZXh0ZW5kcyBTdGF0ZWxlc3NXaWRnZXQgewogIGNvbnN0IEdhbWVNb2JpbGVBY3Rpb25CYXIoewogICAgcmVxdWlyZWQgdGhpcy5wbGF5ZXIsCiAgICByZXF1aXJlZCB0aGlzLmJ1c3ksCiAgICByZXF1aXJlZCB0aGlzLmhhc1dpbm5lciwKICAgIHJlcXVpcmVkIHRoaXMub25QcmVzc2VkLAogICAgc3VwZXIua2V5LAogIH0pOwoKICBmaW5hbCBQbGF5ZXJEYXRhIHBsYXllcjsKICBmaW5hbCBib29sIGJ1c3k7CiAgZmluYWwgYm9vbCBoYXNXaW5uZXI7CiAgZmluYWwgVm9pZENhbGxiYWNrIG9uUHJlc3NlZDsKCiAgQG92ZXJyaWRlCiAgV2lkZ2V0IGJ1aWxkKEJ1aWxkQ29udGV4dCBjb250ZXh0KSB7CiAgICBmaW5hbCBlbmFibGVkID0gIWJ1c3kgJiYgIWhhc1dpbm5lcjsKICAgIGZpbmFsIGxhYmVsID0gR2FtZVVpTWV0cmljcy5hY3Rpb25MYWJlbCgKICAgICAgYnVzeTogYnVzeSwKICAgICAgaGFzQWxsQmFkZ2VzOiBwbGF5ZXIuaGFzQWxsQmFkZ2VzLAogICAgKTsKICAgIGZpbmFsIGljb24gPSBHYW1lVWlNZXRyaWNzLmFjdGlvbkljb24oCiAgICAgIGJ1c3k6IGJ1c3ksCiAgICAgIGhhc0FsbEJhZGdlczogcGxheWVyLmhhc0FsbEJhZGdlcywKICAgICk7CgogICAgcmV0dXJuIFNhZmVBcmVhKAogICAgICB0b3A6IGZhbHNlLAogICAgICBjaGlsZDogTWF0ZXJpYWwoCiAgICAgICAgY29sb3I6IENvbG9ycy53aGl0ZSwKICAgICAgICBlbGV2YXRpb246IDE4LAogICAgICAgIGNoaWxkOiBDb250YWluZXIoCiAgICAgICAgICBwYWRkaW5nOiBjb25zdCBFZGdlSW5zZXRzLmZyb21MVFJCKDE0LCAxMCwgMTQsIDEyKSwKICAgICAgICAgIGRlY29yYXRpb246IEJveERlY29yYXRpb24oCiAgICAgICAgICAgIGJvcmRlcjogQm9yZGVyKAogICAgICAgICAgICAgIHRvcDogQm9yZGVyU2lkZSgKICAgICAgICAgICAgICAgIGNvbG9yOiBwbGF5ZXIuY29sb3Iud2l0aFZhbHVlcyhhbHBoYTogMC4yNCksCiAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgKSwKICAgICAgICAgICksCiAgICAgICAgICBjaGlsZDogUm93KAogICAgICAgICAgICBjaGlsZHJlbjogWwogICAgICAgICAgICAgIENvbnRhaW5lcigKICAgICAgICAgICAgICAgIHdpZHRoOiA0NCwKICAgICAgICAgICAgICAgIGhlaWdodDogNDQsCiAgICAgICAgICAgICAgICBhbGlnbm1lbnQ6IEFsaWdubWVudC5jZW50ZXIsCiAgICAgICAgICAgICAgICBkZWNvcmF0aW9uOiBCb3hEZWNvcmF0aW9uKAogICAgICAgICAgICAgICAgICBjb2xvcjogcGxheWVyLmNvbG9yLndpdGhWYWx1ZXMoYWxwaGE6IDAuMTIpLAogICAgICAgICAgICAgICAgICBib3JkZXJSYWRpdXM6IEJvcmRlclJhZGl1cy5jaXJjdWxhcigxNCksCiAgICAgICAgICAgICAgICAgIGJvcmRlcjogQm9yZGVyLmFsbCgKICAgICAgICAgICAgICAgICAgICBjb2xvcjogcGxheWVyLmNvbG9yLndpdGhWYWx1ZXMoYWxwaGE6IDAuMzIpLAogICAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgIGNoaWxkOiBQYXduVG9rZW4oCiAgICAgICAgICAgICAgICAgIHR5cGU6IHBsYXllci5wYXduVHlwZSwKICAgICAgICAgICAgICAgICAgY29sb3I6IHBsYXllci5jb2xvciwKICAgICAgICAgICAgICAgICAgYWN0aXZlOiB0cnVlLAogICAgICAgICAgICAgICAgICB3aWR0aDogMzEsCiAgICAgICAgICAgICAgICAgIGhlaWdodDogMzgsCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgY29uc3QgU2l6ZWRCb3god2lkdGg6IDkpLAogICAgICAgICAgICAgIEV4cGFuZGVkKAogICAgICAgICAgICAgICAgY2hpbGQ6IENvbHVtbigKICAgICAgICAgICAgICAgICAgbWFpbkF4aXNTaXplOiBNYWluQXhpc1NpemUubWluLAogICAgICAgICAgICAgICAgICBjcm9zc0F4aXNBbGlnbm1lbnQ6IENyb3NzQXhpc0FsaWdubWVudC5zdGFydCwKICAgICAgICAgICAgICAgICAgY2hpbGRyZW46IFsKICAgICAgICAgICAgICAgICAgICBUZXh0KAogICAgICAgICAgICAgICAgICAgICAgcGxheWVyLm5hbWUsCiAgICAgICAgICAgICAgICAgICAgICBtYXhMaW5lczogMSwKICAgICAgICAgICAgICAgICAgICAgIG92ZXJmbG93OiBUZXh0T3ZlcmZsb3cuZWxsaXBzaXMsCiAgICAgICAgICAgICAgICAgICAgICBzdHlsZTogY29uc3QgVGV4dFN0eWxlKAogICAgICAgICAgICAgICAgICAgICAgICBmb250U2l6ZTogMTMsCiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRXZWlnaHQ6IEZvbnRXZWlnaHQudzkwMCwKICAgICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgICBUZXh0KAogICAgICAgICAgICAgICAgICAgICAgJyR7cGxheWVyLmJhZGdlcy5sZW5ndGh9LzYgcm96ZXQg4oCiICcKICAgICAgICAgICAgICAgICAgICAgICcke3BsYXllci5jb3JyZWN0QW5zd2Vyc30gZG/En3J1JywKICAgICAgICAgICAgICAgICAgICAgIHN0eWxlOiBjb25zdCBUZXh0U3R5bGUoCiAgICAgICAgICAgICAgICAgICAgICAgIGNvbG9yOiBDb2xvcigweEZGNjQ3NDhCKSwKICAgICAgICAgICAgICAgICAgICAgICAgZm9udFNpemU6IDEwLAogICAgICAgICAgICAgICAgICAgICAgICBmb250V2VpZ2h0OiBGb250V2VpZ2h0Lnc3MDAsCiAgICAgICAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgIF0sCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgY29uc3QgU2l6ZWRCb3god2lkdGg6IDkpLAogICAgICAgICAgICAgIEV4cGFuZGVkKAogICAgICAgICAgICAgICAgZmxleDogMiwKICAgICAgICAgICAgICAgIGNoaWxkOiBGaWxsZWRCdXR0b24uaWNvbigKICAgICAgICAgICAgICAgICAgb25QcmVzc2VkOiBlbmFibGVkID8gb25QcmVzc2VkIDogbnVsbCwKICAgICAgICAgICAgICAgICAgc3R5bGU6IEZpbGxlZEJ1dHRvbi5zdHlsZUZyb20oCiAgICAgICAgICAgICAgICAgICAgYmFja2dyb3VuZENvbG9yOiBwbGF5ZXIuaGFzQWxsQmFkZ2VzCiAgICAgICAgICAgICAgICAgICAgICAgID8gY29uc3QgQ29sb3IoMHhGRkI0NTMwOSkKICAgICAgICAgICAgICAgICAgICAgICAgOiBjb25zdCBDb2xvcigweEZGMEY3NjZFKSwKICAgICAgICAgICAgICAgICAgICBmb3JlZ3JvdW5kQ29sb3I6IENvbG9ycy53aGl0ZSwKICAgICAgICAgICAgICAgICAgICBtaW5pbXVtU2l6ZTogY29uc3QgU2l6ZS5mcm9tSGVpZ2h0KDUyKSwKICAgICAgICAgICAgICAgICAgICBwYWRkaW5nOiBjb25zdCBFZGdlSW5zZXRzLnN5bW1ldHJpYyhob3Jpem9udGFsOiAxMCksCiAgICAgICAgICAgICAgICAgICAgc2hhcGU6IFJvdW5kZWRSZWN0YW5nbGVCb3JkZXIoCiAgICAgICAgICAgICAgICAgICAgICBib3JkZXJSYWRpdXM6IEJvcmRlclJhZGl1cy5jaXJjdWxhcigxNiksCiAgICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgaWNvbjogQW5pbWF0ZWRTd2l0Y2hlcigKICAgICAgICAgICAgICAgICAgICBkdXJhdGlvbjogY29uc3QgRHVyYXRpb24obWlsbGlzZWNvbmRzOiAxODApLAogICAgICAgICAgICAgICAgICAgIGNoaWxkOiBJY29uKAogICAgICAgICAgICAgICAgICAgICAgaWNvbiwKICAgICAgICAgICAgICAgICAgICAgIGtleTogVmFsdWVLZXk8SWNvbkRhdGE+KGljb24pLAogICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgIGxhYmVsOiBUZXh0KAogICAgICAgICAgICAgICAgICAgIGxhYmVsLAogICAgICAgICAgICAgICAgICAgIG1heExpbmVzOiAyLAogICAgICAgICAgICAgICAgICAgIHRleHRBbGlnbjogVGV4dEFsaWduLmNlbnRlciwKICAgICAgICAgICAgICAgICAgICBzdHlsZTogY29uc3QgVGV4dFN0eWxlKAogICAgICAgICAgICAgICAgICAgICAgaGVpZ2h0OiAxLjA1LAogICAgICAgICAgICAgICAgICAgICAgZm9udFdlaWdodDogRm9udFdlaWdodC53OTAwLAogICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICksCiAgICAgICAgICAgIF0sCiAgICAgICAgICApLAogICAgICAgICksCiAgICAgICksCiAgICApOwogIH0KfQoKY2xhc3MgR2FtZVR1cm5IZWFkZXIgZXh0ZW5kcyBTdGF0ZWxlc3NXaWRnZXQgewogIGNvbnN0IEdhbWVUdXJuSGVhZGVyKHsKICAgIHJlcXVpcmVkIHRoaXMucGxheWVyLAogICAgcmVxdWlyZWQgdGhpcy5sYXN0RGljZSwKICAgIHN1cGVyLmtleSwKICB9KTsKCiAgZmluYWwgUGxheWVyRGF0YSBwbGF5ZXI7CiAgZmluYWwgaW50PyBsYXN0RGljZTsKCiAgQG92ZXJyaWRlCiAgV2lkZ2V0IGJ1aWxkKEJ1aWxkQ29udGV4dCBjb250ZXh0KSB7CiAgICByZXR1cm4gQ29udGFpbmVyKAogICAgICBwYWRkaW5nOiBjb25zdCBFZGdlSW5zZXRzLmZyb21MVFJCKDEyLCAxMCwgMTAsIDEwKSwKICAgICAgZGVjb3JhdGlvbjogQm94RGVjb3JhdGlvbigKICAgICAgICBncmFkaWVudDogTGluZWFyR3JhZGllbnQoCiAgICAgICAgICBjb2xvcnM6IFsKICAgICAgICAgICAgcGxheWVyLmNvbG9yLndpdGhWYWx1ZXMoYWxwaGE6IDAuMTYpLAogICAgICAgICAgICBDb2xvcnMud2hpdGUsCiAgICAgICAgICBdLAogICAgICAgICksCiAgICAgICAgYm9yZGVyUmFkaXVzOiBCb3JkZXJSYWRpdXMuY2lyY3VsYXIoMjApLAogICAgICAgIGJvcmRlcjogQm9yZGVyLmFsbCgKICAgICAgICAgIGNvbG9yOiBwbGF5ZXIuY29sb3Iud2l0aFZhbHVlcyhhbHBoYTogMC4zMCksCiAgICAgICAgKSwKICAgICAgKSwKICAgICAgY2hpbGQ6IFJvdygKICAgICAgICBjaGlsZHJlbjogWwogICAgICAgICAgUGF3blRva2VuKAogICAgICAgICAgICB0eXBlOiBwbGF5ZXIucGF3blR5cGUsCiAgICAgICAgICAgIGNvbG9yOiBwbGF5ZXIuY29sb3IsCiAgICAgICAgICAgIGFjdGl2ZTogdHJ1ZSwKICAgICAgICAgICAgd2lkdGg6IDU1LAogICAgICAgICAgICBoZWlnaHQ6IDY4LAogICAgICAgICAgKSwKICAgICAgICAgIGNvbnN0IFNpemVkQm94KHdpZHRoOiAxMSksCiAgICAgICAgICBFeHBhbmRlZCgKICAgICAgICAgICAgY2hpbGQ6IENvbHVtbigKICAgICAgICAgICAgICBjcm9zc0F4aXNBbGlnbm1lbnQ6IENyb3NzQXhpc0FsaWdubWVudC5zdGFydCwKICAgICAgICAgICAgICBjaGlsZHJlbjogWwogICAgICAgICAgICAgICAgY29uc3QgVGV4dCgKICAgICAgICAgICAgICAgICAgJ1NJUkEnLAogICAgICAgICAgICAgICAgICBzdHlsZTogVGV4dFN0eWxlKAogICAgICAgICAgICAgICAgICAgIGNvbG9yOiBDb2xvcigweEZGNjQ3NDhCKSwKICAgICAgICAgICAgICAgICAgICBmb250U2l6ZTogMTAsCiAgICAgICAgICAgICAgICAgICAgbGV0dGVyU3BhY2luZzogMSwKICAgICAgICAgICAgICAgICAgICBmb250V2VpZ2h0OiBGb250V2VpZ2h0Lnc5MDAsCiAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgY29uc3QgU2l6ZWRCb3goaGVpZ2h0OiAyKSwKICAgICAgICAgICAgICAgIFRleHQoCiAgICAgICAgICAgICAgICAgIHBsYXllci5uYW1lLAogICAgICAgICAgICAgICAgICBvdmVyZmxvdzogVGV4dE92ZXJmbG93LmVsbGlwc2lzLAogICAgICAgICAgICAgICAgICBzdHlsZTogY29uc3QgVGV4dFN0eWxlKAogICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAyMiwKICAgICAgICAgICAgICAgICAgICBoZWlnaHQ6IDEuMDUsCiAgICAgICAgICAgICAgICAgICAgZm9udFdlaWdodDogRm9udFdlaWdodC53OTAwLAogICAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgIGNvbnN0IFNpemVkQm94KGhlaWdodDogNCksCiAgICAgICAgICAgICAgICBUZXh0KAogICAgICAgICAgICAgICAgICAnJHtwbGF5ZXIuYmFkZ2VzLmxlbmd0aH0vNiByb3pldCDigKIgJwogICAgICAgICAgICAgICAgICAnJHtwbGF5ZXIuY29ycmVjdEFuc3dlcnMgKyBwbGF5ZXIud3JvbmdBbnN3ZXJzfSBjZXZhcCcsCiAgICAgICAgICAgICAgICAgIHN0eWxlOiBjb25zdCBUZXh0U3R5bGUoCiAgICAgICAgICAgICAgICAgICAgY29sb3I6IENvbG9yKDB4RkY2NDc0OEIpLAogICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAxMCwKICAgICAgICAgICAgICAgICAgICBmb250V2VpZ2h0OiBGb250V2VpZ2h0Lnc3MDAsCiAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgIF0sCiAgICAgICAgICAgICksCiAgICAgICAgICApLAogICAgICAgICAgY29uc3QgU2l6ZWRCb3god2lkdGg6IDgpLAogICAgICAgICAgRGljZUZhY2UodmFsdWU6IGxhc3REaWNlKSwKICAgICAgICBdLAogICAgICApLAogICAgKTsKICB9Cn0KCmNsYXNzIEdhbWVCYWRnZVN0cmlwIGV4dGVuZHMgU3RhdGVsZXNzV2lkZ2V0IHsKICBjb25zdCBHYW1lQmFkZ2VTdHJpcCh7CiAgICByZXF1aXJlZCB0aGlzLnBsYXllciwKICAgIHN1cGVyLmtleSwKICB9KTsKCiAgZmluYWwgUGxheWVyRGF0YSBwbGF5ZXI7CgogIEBvdmVycmlkZQogIFdpZGdldCBidWlsZChCdWlsZENvbnRleHQgY29udGV4dCkgewogICAgcmV0dXJuIFJvdygKICAgICAgbWFpbkF4aXNBbGlnbm1lbnQ6IE1haW5BeGlzQWxpZ25tZW50LnNwYWNlQmV0d2VlbiwKICAgICAgY2hpbGRyZW46IFsKICAgICAgICBmb3IgKHZhciBpbmRleCA9IDA7IGluZGV4IDwgR2FtZUNhdGVnb3J5LnZhbHVlcy5sZW5ndGg7IGluZGV4KyspCiAgICAgICAgICBfYmFkZ2UoaW5kZXgpLAogICAgICBdLAogICAgKTsKICB9CgogIFdpZGdldCBfYmFkZ2UoaW50IGluZGV4KSB7CiAgICBmaW5hbCBjYXRlZ29yeSA9IEdhbWVDYXRlZ29yeS52YWx1ZXNbaW5kZXhdOwogICAgZmluYWwgZWFybmVkID0gcGxheWVyLmJhZGdlcy5jb250YWlucyhpbmRleCk7CgogICAgcmV0dXJuIFRvb2x0aXAoCiAgICAgIG1lc3NhZ2U6IGNhdGVnb3J5LmxhYmVsLAogICAgICBjaGlsZDogQW5pbWF0ZWRDb250YWluZXIoCiAgICAgICAgZHVyYXRpb246IGNvbnN0IER1cmF0aW9uKG1pbGxpc2Vjb25kczogMjUwKSwKICAgICAgICB3aWR0aDogMzksCiAgICAgICAgaGVpZ2h0OiAzOSwKICAgICAgICBhbGlnbm1lbnQ6IEFsaWdubWVudC5jZW50ZXIsCiAgICAgICAgZGVjb3JhdGlvbjogQm94RGVjb3JhdGlvbigKICAgICAgICAgIGNvbG9yOiBlYXJuZWQgPyBjYXRlZ29yeS5jb2xvciA6IGNvbnN0IENvbG9yKDB4RkZGMUY1RjkpLAogICAgICAgICAgc2hhcGU6IEJveFNoYXBlLmNpcmNsZSwKICAgICAgICAgIGJvcmRlcjogQm9yZGVyLmFsbCgKICAgICAgICAgICAgY29sb3I6IGVhcm5lZCA/IENvbG9ycy53aGl0ZSA6IGNvbnN0IENvbG9yKDB4RkZDQkQ1RTEpLAogICAgICAgICAgICB3aWR0aDogMiwKICAgICAgICAgICksCiAgICAgICAgICBib3hTaGFkb3c6IGVhcm5lZAogICAgICAgICAgICAgID8gWwogICAgICAgICAgICAgICAgICBCb3hTaGFkb3coCiAgICAgICAgICAgICAgICAgICAgYmx1clJhZGl1czogOCwKICAgICAgICAgICAgICAgICAgICBzcHJlYWRSYWRpdXM6IDEsCiAgICAgICAgICAgICAgICAgICAgY29sb3I6IGNhdGVnb3J5LmNvbG9yLndpdGhWYWx1ZXMoYWxwaGE6IDAuMzYpLAogICAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgXQogICAgICAgICAgICAgIDogbnVsbCwKICAgICAgICApLAogICAgICAgIGNoaWxkOiBUZXh0KAogICAgICAgICAgZWFybmVkID8gJ+KckycgOiBjYXRlZ29yeS5lbW9qaSwKICAgICAgICAgIHN0eWxlOiBUZXh0U3R5bGUoCiAgICAgICAgICAgIGZvbnRXZWlnaHQ6IGVhcm5lZCA/IEZvbnRXZWlnaHQudzkwMCA6IEZvbnRXZWlnaHQubm9ybWFsLAogICAgICAgICAgKSwKICAgICAgICApLAogICAgICApLAogICAgKTsKICB9Cn0KCmNsYXNzIEdhbWVTdGF0dXNCYW5uZXIgZXh0ZW5kcyBTdGF0ZWxlc3NXaWRnZXQgewogIGNvbnN0IEdhbWVTdGF0dXNCYW5uZXIoewogICAgcmVxdWlyZWQgdGhpcy5zdGF0dXMsCiAgICByZXF1aXJlZCB0aGlzLmJ1c3ksCiAgICByZXF1aXJlZCB0aGlzLndhaXRpbmdGb3JSb3V0ZSwKICAgIHJlcXVpcmVkIHRoaXMucGxheWVyQ29sb3IsCiAgICBzdXBlci5rZXksCiAgfSk7CgogIGZpbmFsIFN0cmluZyBzdGF0dXM7CiAgZmluYWwgYm9vbCBidXN5OwogIGZpbmFsIGJvb2wgd2FpdGluZ0ZvclJvdXRlOwogIGZpbmFsIENvbG9yIHBsYXllckNvbG9yOwoKICBAb3ZlcnJpZGUKICBXaWRnZXQgYnVpbGQoQnVpbGRDb250ZXh0IGNvbnRleHQpIHsKICAgIGZpbmFsIGxvd2VyID0gc3RhdHVzLnRvTG93ZXJDYXNlKCk7CgogICAgZmluYWwgSWNvbkRhdGEgaWNvbjsKICAgIGZpbmFsIENvbG9yIGFjY2VudDsKCiAgICBpZiAod2FpdGluZ0ZvclJvdXRlKSB7CiAgICAgIGljb24gPSBJY29ucy5hbHRfcm91dGVfcm91bmRlZDsKICAgICAgYWNjZW50ID0gY29uc3QgQ29sb3IoMHhGRjI1NjNFQik7CiAgICB9IGVsc2UgaWYgKGJ1c3kpIHsKICAgICAgaWNvbiA9IEljb25zLmhvdXJnbGFzc190b3Bfcm91bmRlZDsKICAgICAgYWNjZW50ID0gY29uc3QgQ29sb3IoMHhGRjdDM0FFRCk7CiAgICB9IGVsc2UgaWYgKGxvd2VyLmNvbnRhaW5zKCdkb8SfcnUnKSkgewogICAgICBpY29uID0gSWNvbnMuY2hlY2tfY2lyY2xlX3JvdW5kZWQ7CiAgICAgIGFjY2VudCA9IGNvbnN0IENvbG9yKDB4RkYxNkEzNEEpOwogICAgfSBlbHNlIGlmIChsb3dlci5jb250YWlucygneWFubMSxxZ8nKSkgewogICAgICBpY29uID0gSWNvbnMuY2FuY2VsX3JvdW5kZWQ7CiAgICAgIGFjY2VudCA9IGNvbnN0IENvbG9yKDB4RkZEQzI2MjYpOwogICAgfSBlbHNlIGlmIChsb3dlci5jb250YWlucygncm96ZXQnKSkgewogICAgICBpY29uID0gSWNvbnMud29ya3NwYWNlX3ByZW1pdW1fcm91bmRlZDsKICAgICAgYWNjZW50ID0gY29uc3QgQ29sb3IoMHhGRkI0NTMwOSk7CiAgICB9IGVsc2UgewogICAgICBpY29uID0gSWNvbnMuZXhwbG9yZV9yb3VuZGVkOwogICAgICBhY2NlbnQgPSBwbGF5ZXJDb2xvcjsKICAgIH0KCiAgICByZXR1cm4gUGFkZGluZygKICAgICAgcGFkZGluZzogY29uc3QgRWRnZUluc2V0cy5mcm9tTFRSQigxMiwgNCwgMTIsIDE0KSwKICAgICAgY2hpbGQ6IEFuaW1hdGVkQ29udGFpbmVyKAogICAgICAgIGR1cmF0aW9uOiBjb25zdCBEdXJhdGlvbihtaWxsaXNlY29uZHM6IDIyMCksCiAgICAgICAgcGFkZGluZzogY29uc3QgRWRnZUluc2V0cy5zeW1tZXRyaWMoaG9yaXpvbnRhbDogMTMsIHZlcnRpY2FsOiAxMSksCiAgICAgICAgZGVjb3JhdGlvbjogQm94RGVjb3JhdGlvbigKICAgICAgICAgIGNvbG9yOiBhY2NlbnQud2l0aFZhbHVlcyhhbHBoYTogMC4xMCksCiAgICAgICAgICBib3JkZXJSYWRpdXM6IEJvcmRlclJhZGl1cy5jaXJjdWxhcigxNiksCiAgICAgICAgICBib3JkZXI6IEJvcmRlci5hbGwoCiAgICAgICAgICAgIGNvbG9yOiBhY2NlbnQud2l0aFZhbHVlcyhhbHBoYTogMC4yOCksCiAgICAgICAgICApLAogICAgICAgICksCiAgICAgICAgY2hpbGQ6IFJvdygKICAgICAgICAgIG1haW5BeGlzQWxpZ25tZW50OiBNYWluQXhpc0FsaWdubWVudC5jZW50ZXIsCiAgICAgICAgICBjaGlsZHJlbjogWwogICAgICAgICAgICBBbmltYXRlZFN3aXRjaGVyKAogICAgICAgICAgICAgIGR1cmF0aW9uOiBjb25zdCBEdXJhdGlvbihtaWxsaXNlY29uZHM6IDE4MCksCiAgICAgICAgICAgICAgY2hpbGQ6IEljb24oCiAgICAgICAgICAgICAgICBpY29uLAogICAgICAgICAgICAgICAga2V5OiBWYWx1ZUtleTxJY29uRGF0YT4oaWNvbiksCiAgICAgICAgICAgICAgICBjb2xvcjogYWNjZW50LAogICAgICAgICAgICAgICAgc2l6ZTogMjAsCiAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgKSwKICAgICAgICAgICAgY29uc3QgU2l6ZWRCb3god2lkdGg6IDgpLAogICAgICAgICAgICBGbGV4aWJsZSgKICAgICAgICAgICAgICBjaGlsZDogQW5pbWF0ZWRTd2l0Y2hlcigKICAgICAgICAgICAgICAgIGR1cmF0aW9uOiBjb25zdCBEdXJhdGlvbihtaWxsaXNlY29uZHM6IDE4MCksCiAgICAgICAgICAgICAgICBjaGlsZDogVGV4dCgKICAgICAgICAgICAgICAgICAgc3RhdHVzLAogICAgICAgICAgICAgICAgICBrZXk6IFZhbHVlS2V5PFN0cmluZz4oc3RhdHVzKSwKICAgICAgICAgICAgICAgICAgdGV4dEFsaWduOiBUZXh0QWxpZ24uY2VudGVyLAogICAgICAgICAgICAgICAgICBzdHlsZTogY29uc3QgVGV4dFN0eWxlKAogICAgICAgICAgICAgICAgICAgIGhlaWdodDogMS4yLAogICAgICAgICAgICAgICAgICAgIGZvbnRXZWlnaHQ6IEZvbnRXZWlnaHQudzgwMCwKICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgKSwKICAgICAgICAgIF0sCiAgICAgICAgKSwKICAgICAgKSwKICAgICk7CiAgfQp9CgpjbGFzcyBHYW1lUHJvZ3Jlc3NTdW1tYXJ5IGV4dGVuZHMgU3RhdGVsZXNzV2lkZ2V0IHsKICBjb25zdCBHYW1lUHJvZ3Jlc3NTdW1tYXJ5KHsKICAgIHJlcXVpcmVkIHRoaXMucGxheWVyLAogICAgcmVxdWlyZWQgdGhpcy5kaWZmaWN1bHR5VGV4dCwKICAgIHJlcXVpcmVkIHRoaXMudXNlZFF1ZXN0aW9uQ291bnQsCiAgICByZXF1aXJlZCB0aGlzLnRvdGFsUXVlc3Rpb25Db3VudCwKICAgIHN1cGVyLmtleSwKICB9KTsKCiAgZmluYWwgUGxheWVyRGF0YSBwbGF5ZXI7CiAgZmluYWwgU3RyaW5nIGRpZmZpY3VsdHlUZXh0OwogIGZpbmFsIGludCB1c2VkUXVlc3Rpb25Db3VudDsKICBmaW5hbCBpbnQgdG90YWxRdWVzdGlvbkNvdW50OwoKICBAb3ZlcnJpZGUKICBXaWRnZXQgYnVpbGQoQnVpbGRDb250ZXh0IGNvbnRleHQpIHsKICAgIHJldHVybiBDb2x1bW4oCiAgICAgIGNoaWxkcmVuOiBbCiAgICAgICAgUm93KAogICAgICAgICAgY2hpbGRyZW46IFsKICAgICAgICAgICAgRXhwYW5kZWQoCiAgICAgICAgICAgICAgY2hpbGQ6IF9zdGF0KAogICAgICAgICAgICAgICAgZW1vamk6ICfinIUnLAogICAgICAgICAgICAgICAgdmFsdWU6ICcke3BsYXllci5jb3JyZWN0QW5zd2Vyc30nLAogICAgICAgICAgICAgICAgbGFiZWw6ICdEb8SfcnUnLAogICAgICAgICAgICAgICAgY29sb3I6IGNvbnN0IENvbG9yKDB4RkYxNkEzNEEpLAogICAgICAgICAgICAgICksCiAgICAgICAgICAgICksCiAgICAgICAgICAgIGNvbnN0IFNpemVkQm94KHdpZHRoOiA3KSwKICAgICAgICAgICAgRXhwYW5kZWQoCiAgICAgICAgICAgICAgY2hpbGQ6IF9zdGF0KAogICAgICAgICAgICAgICAgZW1vamk6ICfinYwnLAogICAgICAgICAgICAgICAgdmFsdWU6ICcke3BsYXllci53cm9uZ0Fuc3dlcnN9JywKICAgICAgICAgICAgICAgIGxhYmVsOiAnWWFubMSxxZ8nLAogICAgICAgICAgICAgICAgY29sb3I6IGNvbnN0IENvbG9yKDB4RkZEQzI2MjYpLAogICAgICAgICAgICAgICksCiAgICAgICAgICAgICksCiAgICAgICAgICAgIGNvbnN0IFNpemVkQm94KHdpZHRoOiA3KSwKICAgICAgICAgICAgRXhwYW5kZWQoCiAgICAgICAgICAgICAgY2hpbGQ6IF9zdGF0KAogICAgICAgICAgICAgICAgZW1vamk6ICfwn6epJywKICAgICAgICAgICAgICAgIHZhbHVlOiAnJHVzZWRRdWVzdGlvbkNvdW50JywKICAgICAgICAgICAgICAgIGxhYmVsOiAnRmFya2zEsSBzb3J1JywKICAgICAgICAgICAgICAgIGNvbG9yOiBjb25zdCBDb2xvcigweEZGMjU2M0VCKSwKICAgICAgICAgICAgICApLAogICAgICAgICAgICApLAogICAgICAgICAgXSwKICAgICAgICApLAogICAgICAgIGNvbnN0IFNpemVkQm94KGhlaWdodDogOCksCiAgICAgICAgQ29udGFpbmVyKAogICAgICAgICAgd2lkdGg6IGRvdWJsZS5pbmZpbml0eSwKICAgICAgICAgIHBhZGRpbmc6IGNvbnN0IEVkZ2VJbnNldHMuc3ltbWV0cmljKGhvcml6b250YWw6IDExLCB2ZXJ0aWNhbDogOSksCiAgICAgICAgICBkZWNvcmF0aW9uOiBCb3hEZWNvcmF0aW9uKAogICAgICAgICAgICBjb2xvcjogY29uc3QgQ29sb3IoMHhGRjE1NUU3NSkud2l0aFZhbHVlcyhhbHBoYTogMC4wOCksCiAgICAgICAgICAgIGJvcmRlclJhZGl1czogQm9yZGVyUmFkaXVzLmNpcmN1bGFyKDE0KSwKICAgICAgICAgICAgYm9yZGVyOiBCb3JkZXIuYWxsKAogICAgICAgICAgICAgIGNvbG9yOiBjb25zdCBDb2xvcigweEZGMTU1RTc1KS53aXRoVmFsdWVzKGFscGhhOiAwLjIyKSwKICAgICAgICAgICAgKSwKICAgICAgICAgICksCiAgICAgICAgICBjaGlsZDogVGV4dCgKICAgICAgICAgICAgJ/Cfp6AgJGRpZmZpY3VsdHlUZXh0IOKAoiAnCiAgICAgICAgICAgICckdXNlZFF1ZXN0aW9uQ291bnQvJHRvdGFsUXVlc3Rpb25Db3VudCBzb3J1JywKICAgICAgICAgICAgbWF4TGluZXM6IDIsCiAgICAgICAgICAgIG92ZXJmbG93OiBUZXh0T3ZlcmZsb3cuZWxsaXBzaXMsCiAgICAgICAgICAgIHRleHRBbGlnbjogVGV4dEFsaWduLmNlbnRlciwKICAgICAgICAgICAgc3R5bGU6IGNvbnN0IFRleHRTdHlsZSgKICAgICAgICAgICAgICBmb250U2l6ZTogMTAsCiAgICAgICAgICAgICAgaGVpZ2h0OiAxLjI1LAogICAgICAgICAgICAgIGZvbnRXZWlnaHQ6IEZvbnRXZWlnaHQudzgwMCwKICAgICAgICAgICAgKSwKICAgICAgICAgICksCiAgICAgICAgKSwKICAgICAgXSwKICAgICk7CiAgfQoKICBXaWRnZXQgX3N0YXQoewogICAgcmVxdWlyZWQgU3RyaW5nIGVtb2ppLAogICAgcmVxdWlyZWQgU3RyaW5nIHZhbHVlLAogICAgcmVxdWlyZWQgU3RyaW5nIGxhYmVsLAogICAgcmVxdWlyZWQgQ29sb3IgY29sb3IsCiAgfSkgewogICAgcmV0dXJuIENvbnRhaW5lcigKICAgICAgcGFkZGluZzogY29uc3QgRWRnZUluc2V0cy5zeW1tZXRyaWMoaG9yaXpvbnRhbDogNCwgdmVydGljYWw6IDkpLAogICAgICBkZWNvcmF0aW9uOiBCb3hEZWNvcmF0aW9uKAogICAgICAgIGNvbG9yOiBjb2xvci53aXRoVmFsdWVzKGFscGhhOiAwLjA4KSwKICAgICAgICBib3JkZXJSYWRpdXM6IEJvcmRlclJhZGl1cy5jaXJjdWxhcigxNCksCiAgICAgICAgYm9yZGVyOiBCb3JkZXIuYWxsKAogICAgICAgICAgY29sb3I6IGNvbG9yLndpdGhWYWx1ZXMoYWxwaGE6IDAuMjApLAogICAgICAgICksCiAgICAgICksCiAgICAgIGNoaWxkOiBDb2x1bW4oCiAgICAgICAgY2hpbGRyZW46IFsKICAgICAgICAgIFRleHQoZW1vamkpLAogICAgICAgICAgY29uc3QgU2l6ZWRCb3goaGVpZ2h0OiAyKSwKICAgICAgICAgIFRleHQoCiAgICAgICAgICAgIHZhbHVlLAogICAgICAgICAgICBzdHlsZTogVGV4dFN0eWxlKAogICAgICAgICAgICAgIGNvbG9yOiBjb2xvciwKICAgICAgICAgICAgICBmb250U2l6ZTogMTcsCiAgICAgICAgICAgICAgZm9udFdlaWdodDogRm9udFdlaWdodC53OTAwLAogICAgICAgICAgICApLAogICAgICAgICAgKSwKICAgICAgICAgIFRleHQoCiAgICAgICAgICAgIGxhYmVsLAogICAgICAgICAgICBtYXhMaW5lczogMSwKICAgICAgICAgICAgb3ZlcmZsb3c6IFRleHRPdmVyZmxvdy5lbGxpcHNpcywKICAgICAgICAgICAgc3R5bGU6IGNvbnN0IFRleHRTdHlsZSgKICAgICAgICAgICAgICBjb2xvcjogQ29sb3IoMHhGRjY0NzQ4QiksCiAgICAgICAgICAgICAgZm9udFNpemU6IDgsCiAgICAgICAgICAgICAgZm9udFdlaWdodDogRm9udFdlaWdodC53NzAwLAogICAgICAgICAgICApLAogICAgICAgICAgKSwKICAgICAgICBdLAogICAgICApLAogICAgKTsKICB9Cn0K"""

def run(command):
    print("$ " + " ".join(command))
    return subprocess.run(command, check=True)

for path in [MAIN, PUBSPEC, TEST]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulumu BilgiRotasi deposunun ana klasöründe çalıştır."
        )

branch = subprocess.check_output(
    ["git", "branch", "--show-current"],
    text=True,
).strip()

if branch != "main":
    raise SystemExit(
        "Bu geliştirme yalnızca main dalına kurulabilir.\n"
        f"Şu anki dal: {branch or '(belirsiz)'}\n"
        "Önce: git switch main"
    )

question_status = subprocess.run(
    ["git", "status", "--porcelain", "--", "assets/questions.json"],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()

if question_status:
    raise SystemExit(
        "assets/questions.json dosyasında yerel değişiklik var.\n"
        "Soru çalışmalarını ayrı branch'te bırakıp main dalını "
        "temizledikten sonra bu paketi çalıştır."
    )

main = MAIN.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")

if "part 'game_ui_polish.dart';" in main or TARGET.exists():
    raise SystemExit(
        "Oyun içi arayüz rötuşları zaten kurulmuş görünüyor."
    )

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)

if version_match is None:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

version = tuple(map(int, version_match.groups()))

if version != (1, 35, 0, 45):
    raise SystemExit(
        "Bu paket 1.35.0+45 sürümü için hazırlandı.\n"
        f"Depodaki sürüm: "
        f"{version[0]}.{version[1]}.{version[2]}+{version[3]}"
    )

required_markers = [
    "part 'main_navigation.dart';",
    "class _GameScreenState extends State<GameScreen>",
    "Widget _buildBoardCard()",
    "Widget _buildControlPanel()",
    "Bilgi Rotası • Sürüm 1.35.0",
]

for marker in required_markers:
    if marker not in main:
        raise SystemExit(
            f"Beklenen main.dart bölümü bulunamadı: {marker}"
        )

backup_dir = Path(tempfile.mkdtemp(
    prefix="bilgi_rotasi_game_ui_polish_"
))
committed = False

try:
    shutil.copy2(MAIN, backup_dir / "main.dart")
    shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")
    shutil.copy2(TEST, backup_dir / "system_smoke_test.dart")

    TARGET.write_text(
        base64.b64decode(POLISH_B64).decode("utf-8"),
        encoding="utf-8",
    )

    main = main.replace(
        "part 'main_navigation.dart';",
        "part 'main_navigation.dart';\n"
        "part 'game_ui_polish.dart';",
        1,
    )

    class_start = main.index(
        "class _GameScreenState extends State<GameScreen>"
    )
    class_end = main.index(
        "\nclass PawnDefinition",
        class_start,
    )
    game = main[class_start:class_end]

    build_marker = """  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
"""
    if build_marker not in game:
        raise RuntimeError("GameScreen build başlangıcı bulunamadı.")

    game = game.replace(
        build_marker,
        """  @override
  Widget build(BuildContext context) {
    final compactLayout = GameUiMetrics.isCompact(
      MediaQuery.sizeOf(context).width,
    );

    return PopScope<Object?>(
""",
        1,
    )

    scaffold_body_marker = """        ],
      ),
      body: SafeArea(
"""
    if scaffold_body_marker not in game:
        raise RuntimeError(
            "GameScreen alt eylem çubuğu ekleme noktası bulunamadı."
        )

    game = game.replace(
        scaffold_body_marker,
        """        ],
      ),
      bottomNavigationBar: compactLayout
          ? GameMobileActionBar(
              player: _currentPlayer,
              busy: _isBusy,
              hasWinner: _winner != null,
              onPressed: _onMainAction,
            )
          : null,
      body: SafeArea(
""",
        1,
    )

    wide_old = "SizedBox(width: 350, child: _buildControlPanel()),"
    if wide_old not in game:
        raise RuntimeError("Geniş ekran kontrol paneli bulunamadı.")
    game = game.replace(
        wide_old,
        """SizedBox(
                          width: 350,
                          child: _buildControlPanel(
                            showMainAction: true,
                          ),
                        ),""",
        1,
    )

    narrow_old = """            return ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              clipBehavior: Clip.none,
              children: [
                _buildBoardCard(),
                const SizedBox(height: 14),
                _buildControlPanel(),
              ],
            );
"""
    narrow_new = """            return ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 112),
              clipBehavior: Clip.none,
              children: [
                _buildBoardCard(),
                const SizedBox(height: 10),
                _buildControlPanel(
                  showMainAction: false,
                ),
              ],
            );
"""
    if narrow_old not in game:
        raise RuntimeError("Telefon GameScreen yerleşimi bulunamadı.")
    game = game.replace(narrow_old, narrow_new, 1)

    board_old = """            LayoutBuilder(
              builder: (context, constraints) {
                final boardSize = constraints.maxWidth * 1.10;

                return SizedBox(
                  height: boardSize,
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minWidth: boardSize,
                    maxWidth: boardSize,
                    minHeight: boardSize,
                    maxHeight: boardSize,
                    child: GameBoard(
                      players: widget.players,
                      currentPlayerIndex: _currentPlayerIndex,
                      moveOptions: _moveOptions,
                      onMoveSelected: _selectMoveFromBoard,
                      activeMove: _activeMove,
                      routeOpacity: _routeOpacity,
                      landingNodeId: _landingNodeId,
                      landingPulse: _landingPulse,
                    ),
                  ),
                );
              },
            ),
"""
    board_new = """            LayoutBuilder(
              builder: (context, constraints) {
                final boardSize = GameUiMetrics.boardSize(
                  constraints.maxWidth,
                );

                return Center(
                  child: SizedBox.square(
                    dimension: boardSize,
                    child: GameBoard(
                      players: widget.players,
                      currentPlayerIndex: _currentPlayerIndex,
                      moveOptions: _moveOptions,
                      onMoveSelected: _selectMoveFromBoard,
                      activeMove: _activeMove,
                      routeOpacity: _routeOpacity,
                      landingNodeId: _landingNodeId,
                      landingPulse: _landingPulse,
                    ),
                  ),
                );
              },
            ),
"""
    if board_old not in game:
        raise RuntimeError("Tahta boyutlandırma bölümü bulunamadı.")
    game = game.replace(board_old, board_new, 1)

    status_old = """            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
"""
    status_new = """            GameStatusBanner(
              status: _status,
              busy: _isBusy,
              waitingForRoute: _moveOptions.isNotEmpty,
              playerColor: _currentPlayer.color,
            ),
"""
    if status_old not in game:
        raise RuntimeError("Tahta durum mesajı bölümü bulunamadı.")
    game = game.replace(status_old, status_new, 1)

    game = game.replace(
        "  Widget _buildControlPanel() {",
        """  Widget _buildControlPanel({
    required bool showMainAction,
  }) {""",
        1,
    )

    header_old = """                Row(
                  children: [
                    PawnToken(
                      type: _currentPlayer.pawnType,
                      color: _currentPlayer.color,
                      active: true,
                      width: 58,
                      height: 72,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sıra', style: TextStyle(fontSize: 13)),
                          Text(
                            _currentPlayer.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DiceFace(value: _lastDice),
                  ],
                ),
"""
    header_new = """                GameTurnHeader(
                  player: _currentPlayer,
                  lastDice: _lastDice,
                ),
"""
    if header_old not in game:
        raise RuntimeError("Oyuncu sıra başlığı bulunamadı.")
    game = game.replace(header_old, header_new, 1)

    badges_old = """                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(GameCategory.values.length, (index) {
                    final category = GameCategory.values[index];
                    final earned = _currentPlayer.badges.contains(index);
                    return Tooltip(
                      message: category.label,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: earned ? category.color : const Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: earned ? Colors.white : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                          boxShadow: earned
                              ? const [
                                  BoxShadow(
                                    blurRadius: 6,
                                    color: Color(0x33000000),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(earned ? '✓' : category.emoji),
                      ),
                    );
                  }),
                ),
"""
    badges_new = """                GameBadgeStrip(
                  player: _currentPlayer,
                ),
"""
    if badges_old not in game:
        raise RuntimeError("Rozet şeridi bölümü bulunamadı.")
    game = game.replace(badges_old, badges_new, 1)

    action_old = """                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isBusy || _winner != null ? null : _onMainAction,
                  icon: Icon(
                    _currentPlayer.hasAllBadges
                        ? Icons.emoji_events_rounded
                        : Icons.casino_rounded,
                  ),
                  label: Text(
                    _isBusy
                        ? 'Bekle…'
                        : _currentPlayer.hasAllBadges
                            ? 'Final Sorusuna Geç'
                            : 'Zarı At',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 10),
"""
    action_new = """                if (showMainAction) ...[
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _isBusy || _winner != null
                        ? null
                        : _onMainAction,
                    icon: Icon(
                      GameUiMetrics.actionIcon(
                        busy: _isBusy,
                        hasAllBadges:
                            _currentPlayer.hasAllBadges,
                      ),
                    ),
                    label: Text(
                      GameUiMetrics.actionLabel(
                        busy: _isBusy,
                        hasAllBadges:
                            _currentPlayer.hasAllBadges,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else
                  const SizedBox(height: 12),
"""
    if action_old not in game:
        raise RuntimeError("Zar/Final ana eylem düğmesi bulunamadı.")
    game = game.replace(action_old, action_new, 1)

    progress_old = """                const SizedBox(height: 9),
                Text(
                  'Doğru: ${_currentPlayer.correctAnswers}   •   '
                  'Yanlış: ${_currentPlayer.wrongAnswers}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF155E75).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xFF155E75)
                          .withOpacity(0.22),
                    ),
                  ),
                  child: Text(
                    '🧠 Soru seviyesi: '
                    '$_difficultyStatusText   •   '
                    '${_usedQuestionIds.length}/'
                    '${widget.questionBank.totalCount} farklı soru',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
"""
    progress_new = """                const SizedBox(height: 9),
                GameProgressSummary(
                  player: _currentPlayer,
                  difficultyText: _difficultyStatusText,
                  usedQuestionCount: _usedQuestionIds.length,
                  totalQuestionCount:
                      widget.questionBank.totalCount,
                ),
"""
    if progress_old not in game:
        raise RuntimeError("Oyuncu ilerleme özeti bölümü bulunamadı.")
    game = game.replace(progress_old, progress_new, 1)

    main = main[:class_start] + game + main[class_end:]

    main, version_text_count = re.subn(
        r"Bilgi Rotası • Sürüm 1\.35\.0",
        "Bilgi Rotası • Sürüm 1.36.0",
        main,
        count=1,
    )
    if version_text_count != 1:
        raise RuntimeError("Ana menü sürüm yazısı güncellenemedi.")

    pubspec = re.sub(
        r"^version:\s*.*$",
        "version: 1.36.0+46",
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )

    test_insert = """
    test('Oyun arayüzü telefon ve geniş ekranı ayırır', () {
      expect(GameUiMetrics.isCompact(412), isTrue);
      expect(GameUiMetrics.isCompact(760), isFalse);
      expect(GameUiMetrics.boardSize(900), 720);
      expect(
        GameUiMetrics.actionLabel(
          busy: false,
          hasAllBadges: false,
        ),
        'Zarı At',
      );
      expect(
        GameUiMetrics.actionLabel(
          busy: false,
          hasAllBadges: true,
        ),
        'Final Sorusuna Geç',
      );
    });
"""
    group_end = test.rfind("  });\n}")
    if group_end < 0:
        raise RuntimeError("Test dosyası ekleme noktası bulunamadı.")
    test = test[:group_end] + test_insert + test[group_end:]

    MAIN.write_text(main, encoding="utf-8")
    PUBSPEC.write_text(pubspec, encoding="utf-8")
    TEST.write_text(test, encoding="utf-8")

    checks = {
        MAIN: [
            "part 'game_ui_polish.dart';",
            "final compactLayout = GameUiMetrics.isCompact(",
            "GameMobileActionBar(",
            "GameTurnHeader(",
            "GameBadgeStrip(",
            "GameStatusBanner(",
            "GameProgressSummary(",
            "Bilgi Rotası • Sürüm 1.36.0",
        ],
        TARGET: [
            "class GameUiMetrics",
            "class GameMobileActionBar",
            "class GameTurnHeader",
            "class GameBadgeStrip",
            "class GameStatusBanner",
            "class GameProgressSummary",
        ],
        TEST: ["Oyun arayüzü telefon ve geniş ekranı ayırır"],
        PUBSPEC: ["version: 1.36.0+46"],
    }

    for path, markers in checks.items():
        content = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in content:
                raise RuntimeError(
                    f"Kurulum doğrulaması başarısız: {path} / {marker}"
                )

    if shutil.which("dart"):
        run([
            "dart",
            "format",
            "lib/main.dart",
            "lib/game_ui_polish.dart",
            "test/system_smoke_test.dart",
        ])

    run(["git", "diff", "--check"])

    changed_paths = subprocess.check_output(
        ["git", "diff", "--name-only"],
        text=True,
    ).splitlines()

    if "assets/questions.json" in changed_paths:
        raise RuntimeError(
            "Güvenlik kontrolü: questions.json değişmiş görünüyor."
        )

    if shutil.which("flutter"):
        run(["flutter", "pub", "get"])
        run([
            "flutter",
            "analyze",
            "--no-fatal-warnings",
            "--no-fatal-infos",
        ])
        run(["flutter", "test"])
    else:
        print(
            "ℹ️ Flutter bu ortamda bulunamadı; "
            "analiz ve test GitHub Actions'ta çalışacak."
        )

    files_to_stage = [
        "lib/main.dart",
        "lib/game_ui_polish.dart",
        "test/system_smoke_test.dart",
        "pubspec.yaml",
    ]
    if Path("pubspec.lock").exists():
        files_to_stage.append("pubspec.lock")

    run(["git", "add", *files_to_stage])

    changed = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        check=False,
    ).returncode != 0

    if not changed:
        raise RuntimeError("Commit edilecek değişiklik bulunamadı.")

    run([
        "git",
        "commit",
        "-m",
        "Oyun ici arayuzu telefonlara gore duzenle",
    ])
    committed = True
    run(["git", "push", "origin", "main"])

except Exception as error:
    if not committed:
        shutil.copy2(backup_dir / "main.dart", MAIN)
        shutil.copy2(backup_dir / "pubspec.yaml", PUBSPEC)
        shutil.copy2(
            backup_dir / "system_smoke_test.dart",
            TEST,
        )

        if TARGET.exists():
            TARGET.unlink()

        reset_paths = [
            "lib/main.dart",
            "lib/game_ui_polish.dart",
            "test/system_smoke_test.dart",
            "pubspec.yaml",
        ]
        if Path("pubspec.lock").exists():
            reset_paths.append("pubspec.lock")

        subprocess.run(
            ["git", "reset", "--", *reset_paths],
            check=False,
        )

        if shutil.which("flutter"):
            subprocess.run(["flutter", "pub", "get"], check=False)

    print("")
    print("❌ Kurulum tamamlanamadı.")
    print(str(error))

    if committed:
        print(
            "Commit oluşturuldu fakat push başarısız oldu. "
            "Tekrar dene: git push origin main"
        )
    else:
        print("Dosyalar önceki hâline otomatik döndürüldü.")

    raise SystemExit(1)

finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print("")
print("✅ Telefonda Zar At / Final düğmesi ekranın altında sabitlendi.")
print("✅ Tahta artık ekran genişliğine düzgün oturuyor ve taşmıyor.")
print("✅ Sıra kartı, zar, rozetler ve oyun durumu yenilendi.")
print("✅ Doğru, yanlış ve farklı soru bilgileri kompaktlaştırıldı.")
print("✅ Telefon ekranında içerik sabit düğmenin altında kalmıyor.")
print("✅ Geniş ekran yerleşimi korunarak ayrıca desteklendi.")
print("✅ Yeni otomatik arayüz testi eklendi.")
print("✅ questions.json dosyasına dokunulmadı.")
print("✅ Yeni sürüm: 1.36.0+46")
print("✅ Değişiklikler GitHub main dalına gönderildi.")
