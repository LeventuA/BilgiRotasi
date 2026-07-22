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
TARGET = Path("lib/main_navigation.dart")

NAVIGATION_B64 = """cGFydCBvZiAnbWFpbi5kYXJ0JzsKCmVudW0gTWFpbk5hdmlnYXRpb25TZWN0aW9uIHsKICBwbGF5LAogIGRhaWx5LAogIGNhcmVlciwKICBzb2NpYWwsCiAgc2V0dGluZ3MsCn0KCmV4dGVuc2lvbiBNYWluTmF2aWdhdGlvblNlY3Rpb25YIG9uIE1haW5OYXZpZ2F0aW9uU2VjdGlvbiB7CiAgU3RyaW5nIGdldCB0aXRsZSA9PiBzd2l0Y2ggKHRoaXMpIHsKICAgICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24ucGxheSA9PiAnT3luYScsCiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLmRhaWx5ID0+ICdHw7xubMO8aycsCiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLmNhcmVlciA9PiAnS2FyaXllcicsCiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLnNvY2lhbCA9PiAnU29zeWFsJywKICAgICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24uc2V0dGluZ3MgPT4gJ0F5YXJsYXInLAogICAgICB9OwoKICBTdHJpbmcgZ2V0IGVtb2ppID0+IHN3aXRjaCAodGhpcykgewogICAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5wbGF5ID0+ICfwn46uJywKICAgICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24uZGFpbHkgPT4gJ/Cfk4UnLAogICAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5jYXJlZXIgPT4gJ/Cfj4YnLAogICAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5zb2NpYWwgPT4gJ/CfkajigI3wn5Gp4oCN8J+Rp+KAjfCfkaYnLAogICAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5zZXR0aW5ncyA9PiAn4pqZ77iPJywKICAgICAgfTsKCiAgU3RyaW5nIGdldCBkZXNjcmlwdGlvbiA9PiBzd2l0Y2ggKHRoaXMpIHsKICAgICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24ucGxheSA9PgogICAgICAgICAgJ1RhaHRhLCBTZXJiZXN0IFJvdGEsIE1hcmF0b24gdmUgZGnEn2VyIG1vZGxhcicsCiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLmRhaWx5ID0+CiAgICAgICAgICAnR8O8bmzDvGsgZ8O2cmV2LCBoYWZ0YWzEsWsgaGVkZWZsZXIgdmUgbGlnJywKICAgICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24uY2FyZWVyID0+CiAgICAgICAgICAnWFAsIGJhxZ9hcsSxbWxhciwgaXN0YXRpc3Rpa2xlciB2ZSBrb2xla3NpeW9uJywKICAgICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24uc29jaWFsID0+CiAgICAgICAgICAnUGF5bGHFn8SxbSwgYWlsZSByZWtvcmxhcsSxIHZlIG1leWRhbiBva3VtYScsCiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLnNldHRpbmdzID0+CiAgICAgICAgICAnU2VzLCBnw7Zyw7xuw7xtLCBlcmnFn2lsZWJpbGlybGlrIHZlIHRla25payBhcmHDp2xhcicsCiAgICAgIH07CgogIExpc3Q8Q29sb3I+IGdldCBjb2xvcnMgPT4gc3dpdGNoICh0aGlzKSB7CiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLnBsYXkgPT4gY29uc3QgWwogICAgICAgICAgICBDb2xvcigweEZGMEY3NjZFKSwKICAgICAgICAgICAgQ29sb3IoMHhGRjE1NUU3NSksCiAgICAgICAgICBdLAogICAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5kYWlseSA9PiBjb25zdCBbCiAgICAgICAgICAgIENvbG9yKDB4RkZCNDUzMDkpLAogICAgICAgICAgICBDb2xvcigweEZGN0MyRDEyKSwKICAgICAgICAgIF0sCiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLmNhcmVlciA9PiBjb25zdCBbCiAgICAgICAgICAgIENvbG9yKDB4RkY2RDI4RDkpLAogICAgICAgICAgICBDb2xvcigweEZGNDMzOENBKSwKICAgICAgICAgIF0sCiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLnNvY2lhbCA9PiBjb25zdCBbCiAgICAgICAgICAgIENvbG9yKDB4RkZCRTE4NUQpLAogICAgICAgICAgICBDb2xvcigweEZGN0MzQUVEKSwKICAgICAgICAgIF0sCiAgICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLnNldHRpbmdzID0+IGNvbnN0IFsKICAgICAgICAgICAgQ29sb3IoMHhGRjMzNDE1NSksCiAgICAgICAgICAgIENvbG9yKDB4RkYwRjU2NjEpLAogICAgICAgICAgXSwKICAgICAgfTsKfQoKY2xhc3MgTWFpbk5hdmlnYXRpb25HcmlkIGV4dGVuZHMgU3RhdGVsZXNzV2lkZ2V0IHsKICBjb25zdCBNYWluTmF2aWdhdGlvbkdyaWQoewogICAgcmVxdWlyZWQgdGhpcy5xdWVzdGlvbkJhbmssCiAgICBzdXBlci5rZXksCiAgfSk7CgogIGZpbmFsIFF1ZXN0aW9uQmFuayBxdWVzdGlvbkJhbms7CgogIEBvdmVycmlkZQogIFdpZGdldCBidWlsZChCdWlsZENvbnRleHQgY29udGV4dCkgewogICAgcmV0dXJuIENvbHVtbigKICAgICAgY2hpbGRyZW46IFsKICAgICAgICBfcGFpcigKICAgICAgICAgIGNvbnRleHQsCiAgICAgICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24ucGxheSwKICAgICAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5kYWlseSwKICAgICAgICApLAogICAgICAgIGNvbnN0IFNpemVkQm94KGhlaWdodDogMTApLAogICAgICAgIF9wYWlyKAogICAgICAgICAgY29udGV4dCwKICAgICAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5jYXJlZXIsCiAgICAgICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24uc29jaWFsLAogICAgICAgICksCiAgICAgICAgY29uc3QgU2l6ZWRCb3goaGVpZ2h0OiAxMCksCiAgICAgICAgX01haW5OYXZpZ2F0aW9uQ2FyZCgKICAgICAgICAgIHNlY3Rpb246IE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5zZXR0aW5ncywKICAgICAgICAgIGhvcml6b250YWw6IHRydWUsCiAgICAgICAgICBvblRhcDogKCkgPT4gX29wZW4oCiAgICAgICAgICAgIGNvbnRleHQsCiAgICAgICAgICAgIFNldHRpbmdzQ2VudGVyU2NyZWVuKAogICAgICAgICAgICAgIHF1ZXN0aW9uQmFuazogcXVlc3Rpb25CYW5rLAogICAgICAgICAgICApLAogICAgICAgICAgKSwKICAgICAgICApLAogICAgICBdLAogICAgKTsKICB9CgogIFdpZGdldCBfcGFpcigKICAgIEJ1aWxkQ29udGV4dCBjb250ZXh0LAogICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uIGZpcnN0LAogICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uIHNlY29uZCwKICApIHsKICAgIHJldHVybiBJbnRyaW5zaWNIZWlnaHQoCiAgICAgIGNoaWxkOiBSb3coCiAgICAgICAgY3Jvc3NBeGlzQWxpZ25tZW50OiBDcm9zc0F4aXNBbGlnbm1lbnQuc3RyZXRjaCwKICAgICAgICBjaGlsZHJlbjogWwogICAgICAgICAgRXhwYW5kZWQoCiAgICAgICAgICAgIGNoaWxkOiBfTWFpbk5hdmlnYXRpb25DYXJkKAogICAgICAgICAgICAgIHNlY3Rpb246IGZpcnN0LAogICAgICAgICAgICAgIG9uVGFwOiAoKSA9PiBfb3BlblNlY3Rpb24oY29udGV4dCwgZmlyc3QpLAogICAgICAgICAgICApLAogICAgICAgICAgKSwKICAgICAgICAgIGNvbnN0IFNpemVkQm94KHdpZHRoOiAxMCksCiAgICAgICAgICBFeHBhbmRlZCgKICAgICAgICAgICAgY2hpbGQ6IF9NYWluTmF2aWdhdGlvbkNhcmQoCiAgICAgICAgICAgICAgc2VjdGlvbjogc2Vjb25kLAogICAgICAgICAgICAgIG9uVGFwOiAoKSA9PiBfb3BlblNlY3Rpb24oY29udGV4dCwgc2Vjb25kKSwKICAgICAgICAgICAgKSwKICAgICAgICAgICksCiAgICAgICAgXSwKICAgICAgKSwKICAgICk7CiAgfQoKICB2b2lkIF9vcGVuU2VjdGlvbigKICAgIEJ1aWxkQ29udGV4dCBjb250ZXh0LAogICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uIHNlY3Rpb24sCiAgKSB7CiAgICBmaW5hbCBzY3JlZW4gPSBzd2l0Y2ggKHNlY3Rpb24pIHsKICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLnBsYXkgPT4gUGxheUNlbnRlclNjcmVlbigKICAgICAgICAgIHF1ZXN0aW9uQmFuazogcXVlc3Rpb25CYW5rLAogICAgICAgICksCiAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5kYWlseSA9PiBEYWlseUNlbnRlclNjcmVlbigKICAgICAgICAgIHF1ZXN0aW9uQmFuazogcXVlc3Rpb25CYW5rLAogICAgICAgICksCiAgICAgIE1haW5OYXZpZ2F0aW9uU2VjdGlvbi5jYXJlZXIgPT4KICAgICAgICBjb25zdCBDYXJlZXJDZW50ZXJTY3JlZW4oKSwKICAgICAgTWFpbk5hdmlnYXRpb25TZWN0aW9uLnNvY2lhbCA9PiBTb2NpYWxIdWJTY3JlZW4oCiAgICAgICAgICBxdWVzdGlvbkJhbms6IHF1ZXN0aW9uQmFuaywKICAgICAgICApLAogICAgICBNYWluTmF2aWdhdGlvblNlY3Rpb24uc2V0dGluZ3MgPT4gU2V0dGluZ3NDZW50ZXJTY3JlZW4oCiAgICAgICAgICBxdWVzdGlvbkJhbms6IHF1ZXN0aW9uQmFuaywKICAgICAgICApLAogICAgfTsKCiAgICBfb3Blbihjb250ZXh0LCBzY3JlZW4pOwogIH0KCiAgdm9pZCBfb3BlbihCdWlsZENvbnRleHQgY29udGV4dCwgV2lkZ2V0IHNjcmVlbikgewogICAgR2FtZUhhcHRpY3Muc2VsZWN0aW9uQ2xpY2soKTsKICAgIE5hdmlnYXRvci5vZihjb250ZXh0KS5wdXNoKAogICAgICBNYXRlcmlhbFBhZ2VSb3V0ZShidWlsZGVyOiAoXykgPT4gc2NyZWVuKSwKICAgICk7CiAgfQp9CgpjbGFzcyBfTWFpbk5hdmlnYXRpb25DYXJkIGV4dGVuZHMgU3RhdGVsZXNzV2lkZ2V0IHsKICBjb25zdCBfTWFpbk5hdmlnYXRpb25DYXJkKHsKICAgIHJlcXVpcmVkIHRoaXMuc2VjdGlvbiwKICAgIHJlcXVpcmVkIHRoaXMub25UYXAsCiAgICB0aGlzLmhvcml6b250YWwgPSBmYWxzZSwKICB9KTsKCiAgZmluYWwgTWFpbk5hdmlnYXRpb25TZWN0aW9uIHNlY3Rpb247CiAgZmluYWwgVm9pZENhbGxiYWNrIG9uVGFwOwogIGZpbmFsIGJvb2wgaG9yaXpvbnRhbDsKCiAgQG92ZXJyaWRlCiAgV2lkZ2V0IGJ1aWxkKEJ1aWxkQ29udGV4dCBjb250ZXh0KSB7CiAgICBmaW5hbCB0ZXh0ID0gQ29sdW1uKAogICAgICBjcm9zc0F4aXNBbGlnbm1lbnQ6IENyb3NzQXhpc0FsaWdubWVudC5zdGFydCwKICAgICAgbWFpbkF4aXNTaXplOiBNYWluQXhpc1NpemUubWluLAogICAgICBjaGlsZHJlbjogWwogICAgICAgIFRleHQoCiAgICAgICAgICBzZWN0aW9uLnRpdGxlLAogICAgICAgICAgc3R5bGU6IGNvbnN0IFRleHRTdHlsZSgKICAgICAgICAgICAgY29sb3I6IENvbG9ycy53aGl0ZSwKICAgICAgICAgICAgZm9udFNpemU6IDE5LAogICAgICAgICAgICBmb250V2VpZ2h0OiBGb250V2VpZ2h0Lnc5MDAsCiAgICAgICAgICApLAogICAgICAgICksCiAgICAgICAgY29uc3QgU2l6ZWRCb3goaGVpZ2h0OiA0KSwKICAgICAgICBUZXh0KAogICAgICAgICAgc2VjdGlvbi5kZXNjcmlwdGlvbiwKICAgICAgICAgIG1heExpbmVzOiBob3Jpem9udGFsID8gMiA6IDMsCiAgICAgICAgICBvdmVyZmxvdzogVGV4dE92ZXJmbG93LmVsbGlwc2lzLAogICAgICAgICAgc3R5bGU6IGNvbnN0IFRleHRTdHlsZSgKICAgICAgICAgICAgY29sb3I6IENvbG9yKDB4RkZFN0UxRjApLAogICAgICAgICAgICBmb250U2l6ZTogMTEsCiAgICAgICAgICAgIGhlaWdodDogMS4zLAogICAgICAgICAgICBmb250V2VpZ2h0OiBGb250V2VpZ2h0Lnc2MDAsCiAgICAgICAgICApLAogICAgICAgICksCiAgICAgIF0sCiAgICApOwoKICAgIHJldHVybiBNYXRlcmlhbCgKICAgICAgY29sb3I6IENvbG9ycy50cmFuc3BhcmVudCwKICAgICAgY2hpbGQ6IElua1dlbGwoCiAgICAgICAgb25UYXA6IG9uVGFwLAogICAgICAgIGJvcmRlclJhZGl1czogQm9yZGVyUmFkaXVzLmNpcmN1bGFyKDIzKSwKICAgICAgICBjaGlsZDogSW5rKAogICAgICAgICAgcGFkZGluZzogY29uc3QgRWRnZUluc2V0cy5hbGwoMTYpLAogICAgICAgICAgZGVjb3JhdGlvbjogQm94RGVjb3JhdGlvbigKICAgICAgICAgICAgZ3JhZGllbnQ6IExpbmVhckdyYWRpZW50KGNvbG9yczogc2VjdGlvbi5jb2xvcnMpLAogICAgICAgICAgICBib3JkZXJSYWRpdXM6IEJvcmRlclJhZGl1cy5jaXJjdWxhcigyMyksCiAgICAgICAgICAgIGJvcmRlcjogQm9yZGVyLmFsbCgKICAgICAgICAgICAgICBjb2xvcjogY29uc3QgQ29sb3IoMHg1NUZGRkZGRiksCiAgICAgICAgICAgICksCiAgICAgICAgICAgIGJveFNoYWRvdzogY29uc3QgWwogICAgICAgICAgICAgIEJveFNoYWRvdygKICAgICAgICAgICAgICAgIGNvbG9yOiBDb2xvcigweDMzMDAwMDAwKSwKICAgICAgICAgICAgICAgIGJsdXJSYWRpdXM6IDEyLAogICAgICAgICAgICAgICAgb2Zmc2V0OiBPZmZzZXQoMCwgNiksCiAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgXSwKICAgICAgICAgICksCiAgICAgICAgICBjaGlsZDogaG9yaXpvbnRhbAogICAgICAgICAgICAgID8gUm93KAogICAgICAgICAgICAgICAgICBjaGlsZHJlbjogWwogICAgICAgICAgICAgICAgICAgIFRleHQoCiAgICAgICAgICAgICAgICAgICAgICBzZWN0aW9uLmVtb2ppLAogICAgICAgICAgICAgICAgICAgICAgc3R5bGU6IGNvbnN0IFRleHRTdHlsZShmb250U2l6ZTogMzkpLAogICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgICAgY29uc3QgU2l6ZWRCb3god2lkdGg6IDEzKSwKICAgICAgICAgICAgICAgICAgICBFeHBhbmRlZChjaGlsZDogdGV4dCksCiAgICAgICAgICAgICAgICAgICAgY29uc3QgSWNvbigKICAgICAgICAgICAgICAgICAgICAgIEljb25zLmNoZXZyb25fcmlnaHRfcm91bmRlZCwKICAgICAgICAgICAgICAgICAgICAgIGNvbG9yOiBDb2xvcnMud2hpdGUsCiAgICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgXSwKICAgICAgICAgICAgICAgICkKICAgICAgICAgICAgICA6IENvbHVtbigKICAgICAgICAgICAgICAgICAgY3Jvc3NBeGlzQWxpZ25tZW50OiBDcm9zc0F4aXNBbGlnbm1lbnQuc3RhcnQsCiAgICAgICAgICAgICAgICAgIGNoaWxkcmVuOiBbCiAgICAgICAgICAgICAgICAgICAgVGV4dCgKICAgICAgICAgICAgICAgICAgICAgIHNlY3Rpb24uZW1vamksCiAgICAgICAgICAgICAgICAgICAgICBzdHlsZTogY29uc3QgVGV4dFN0eWxlKGZvbnRTaXplOiAzNiksCiAgICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgICBjb25zdCBTaXplZEJveChoZWlnaHQ6IDkpLAogICAgICAgICAgICAgICAgICAgIHRleHQsCiAgICAgICAgICAgICAgICAgICAgY29uc3QgU3BhY2VyKCksCiAgICAgICAgICAgICAgICAgICAgY29uc3QgU2l6ZWRCb3goaGVpZ2h0OiAxMCksCiAgICAgICAgICAgICAgICAgICAgY29uc3QgQWxpZ24oCiAgICAgICAgICAgICAgICAgICAgICBhbGlnbm1lbnQ6IEFsaWdubWVudC5ib3R0b21SaWdodCwKICAgICAgICAgICAgICAgICAgICAgIGNoaWxkOiBJY29uKAogICAgICAgICAgICAgICAgICAgICAgICBJY29ucy5hcnJvd19mb3J3YXJkX3JvdW5kZWQsCiAgICAgICAgICAgICAgICAgICAgICAgIGNvbG9yOiBDb2xvcigweEZGRkZFMDgyKSwKICAgICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgXSwKICAgICAgICAgICAgICAgICksCiAgICAgICAgKSwKICAgICAgKSwKICAgICk7CiAgfQp9CgpjbGFzcyBQbGF5Q2VudGVyU2NyZWVuIGV4dGVuZHMgU3RhdGVsZXNzV2lkZ2V0IHsKICBjb25zdCBQbGF5Q2VudGVyU2NyZWVuKHsKICAgIHJlcXVpcmVkIHRoaXMucXVlc3Rpb25CYW5rLAogICAgc3VwZXIua2V5LAogIH0pOwoKICBmaW5hbCBRdWVzdGlvbkJhbmsgcXVlc3Rpb25CYW5rOwoKICBAb3ZlcnJpZGUKICBXaWRnZXQgYnVpbGQoQnVpbGRDb250ZXh0IGNvbnRleHQpIHsKICAgIHJldHVybiBfTmF2aWdhdGlvbkh1YlNjYWZmb2xkKAogICAgICB0aXRsZTogJ095bmEnLAogICAgICBlbW9qaTogJ/Cfjq4nLAogICAgICBoZWFkbGluZTogJ095dW4gbW9kdW51IHNlw6cnLAogICAgICBzdWJ0aXRsZToKICAgICAgICAgICdLbGFzaWsgdGFodGEgb3l1bnVuZGFuIGjEsXpsxLEgbcO8Y2FkZWxlbGVyZSBrYWRhciAnCiAgICAgICAgICAnYsO8dMO8biBveXVuIHNlw6dlbmVrbGVyaSBidXJhZGEuJywKICAgICAgY29sb3JzOiBjb25zdCBbCiAgICAgICAgQ29sb3IoMHhGRjBGNzY2RSksCiAgICAgICAgQ29sb3IoMHhGRjE1NUU3NSksCiAgICAgIF0sCiAgICAgIGNoaWxkcmVuOiBbCiAgICAgICAgX0h1YkFjdGlvbkNhcmQoCiAgICAgICAgICBlbW9qaTogJ/CfjrInLAogICAgICAgICAgdGl0bGU6ICdTdGFuZGFydCBUYWh0YSBPeXVudScsCiAgICAgICAgICBkZXNjcmlwdGlvbjoKICAgICAgICAgICAgICAnMuKAkzYgb3l1bmN1LCBhbHTEsSByb3pldCB2ZSBmaW5hbCBzb3J1c3V5bGEgJwogICAgICAgICAgICAgICdhbmEgQmlsZ2kgUm90YXPEsSBkZW5leWltaS4nLAogICAgICAgICAgYWNjZW50OiBjb25zdCBDb2xvcigweEZGMEY3NjZFKSwKICAgICAgICAgIG9uVGFwOiAoKSA9PiBfb3BlbigKICAgICAgICAgICAgY29udGV4dCwKICAgICAgICAgICAgUGxheWVyU2V0dXBTY3JlZW4ocXVlc3Rpb25CYW5rOiBxdWVzdGlvbkJhbmspLAogICAgICAgICAgKSwKICAgICAgICApLAogICAgICAgIF9IdWJBY3Rpb25DYXJkKAogICAgICAgICAgZW1vamk6ICfwn6etJywKICAgICAgICAgIHRpdGxlOiAnU2VyYmVzdCBSb3RhJywKICAgICAgICAgIGRlc2NyaXB0aW9uOgogICAgICAgICAgICAgICdUZWsgYmHFn8SxbmEgdGFodGEgw7x6ZXJpbmRlIGlsZXJsZSB2ZSBhbHTEsSByb3pldGkgdG9wbGEuJywKICAgICAgICAgIGFjY2VudDogY29uc3QgQ29sb3IoMHhGRjI1NjNFQiksCiAgICAgICAgICBvblRhcDogKCkgPT4gX29wZW4oCiAgICAgICAgICAgIGNvbnRleHQsCiAgICAgICAgICAgIFNvbG9Sb3V0ZVNldHVwU2NyZWVuKHF1ZXN0aW9uQmFuazogcXVlc3Rpb25CYW5rKSwKICAgICAgICAgICksCiAgICAgICAgKSwKICAgICAgICBfSHViQWN0aW9uQ2FyZCgKICAgICAgICAgIGVtb2ppOiAn8J+noCcsCiAgICAgICAgICB0aXRsZTogJ1NvcnUgTWFyYXRvbnUnLAogICAgICAgICAgZGVzY3JpcHRpb246CiAgICAgICAgICAgICAgJ0thdGVnb3JpIHZlIHNvcnUgc2F5xLFzxLFuxLEgc2XDpzsgaMSxemzEsSBiaXIgYmlsZ2kgdHVydW5hIMOnxLFrLicsCiAgICAgICAgICBhY2NlbnQ6IGNvbnN0IENvbG9yKDB4RkY3QzNBRUQpLAogICAgICAgICAgb25UYXA6ICgpID0+IF9vcGVuKAogICAgICAgICAgICBjb250ZXh0LAogICAgICAgICAgICBNYXJhdGhvblNldHVwU2NyZWVuKHF1ZXN0aW9uQmFuazogcXVlc3Rpb25CYW5rKSwKICAgICAgICAgICksCiAgICAgICAgKSwKICAgICAgICBfSHViQWN0aW9uQ2FyZCgKICAgICAgICAgIGVtb2ppOiAn4pqhJywKICAgICAgICAgIHRpdGxlOiAnRGnEn2VyIE95dW4gTW9kbGFyxLEnLAogICAgICAgICAgZGVzY3JpcHRpb246CiAgICAgICAgICAgICAgJ0hheWF0dGEgS2FsbWEsIDYwIFNhbml5ZSwgQWlsZSwgVGFrxLFtLCAnCiAgICAgICAgICAgICAgJ1R1cm51dmEgdmUgS2FyxLHFn8SxayDDh8SxbGfEsW5sxLFrLicsCiAgICAgICAgICBhY2NlbnQ6IGNvbnN0IENvbG9yKDB4RkZFQTU4MEMpLAogICAgICAgICAgb25UYXA6ICgpID0+IF9vcGVuKAogICAgICAgICAgICBjb250ZXh0LAogICAgICAgICAgICBRdWlja01vZGVzSHViU2NyZWVuKHF1ZXN0aW9uQmFuazogcXVlc3Rpb25CYW5rKSwKICAgICAgICAgICksCiAgICAgICAgKSwKICAgICAgXSwKICAgICk7CiAgfQoKICB2b2lkIF9vcGVuKEJ1aWxkQ29udGV4dCBjb250ZXh0LCBXaWRnZXQgc2NyZWVuKSB7CiAgICBOYXZpZ2F0b3Iub2YoY29udGV4dCkucHVzaCgKICAgICAgTWF0ZXJpYWxQYWdlUm91dGUoYnVpbGRlcjogKF8pID0+IHNjcmVlbiksCiAgICApOwogIH0KfQoKY2xhc3MgRGFpbHlDZW50ZXJTY3JlZW4gZXh0ZW5kcyBTdGF0ZWxlc3NXaWRnZXQgewogIGNvbnN0IERhaWx5Q2VudGVyU2NyZWVuKHsKICAgIHJlcXVpcmVkIHRoaXMucXVlc3Rpb25CYW5rLAogICAgc3VwZXIua2V5LAogIH0pOwoKICBmaW5hbCBRdWVzdGlvbkJhbmsgcXVlc3Rpb25CYW5rOwoKICBAb3ZlcnJpZGUKICBXaWRnZXQgYnVpbGQoQnVpbGRDb250ZXh0IGNvbnRleHQpIHsKICAgIHJldHVybiBfTmF2aWdhdGlvbkh1YlNjYWZmb2xkKAogICAgICB0aXRsZTogJ0fDvG5sw7xrJywKICAgICAgZW1vamk6ICfwn5OFJywKICAgICAgaGVhZGxpbmU6ICdIZXIgZ8O8biB5ZW5pIGJpciBoZWRlZicsCiAgICAgIHN1YnRpdGxlOgogICAgICAgICAgJ0fDvG5sw7xrIHNvcnVsYXLEsSB0YW1hbWxhLCBoYWZ0YWzEsWsgZ8O2cmV2bGVyaSBpbGVybGV0ICcKICAgICAgICAgICd2ZSBsaWcgYmFzYW1ha2xhcsSxbsSxIHTEsXJtYW4uJywKICAgICAgY29sb3JzOiBjb25zdCBbCiAgICAgICAgQ29sb3IoMHhGRkI0NTMwOSksCiAgICAgICAgQ29sb3IoMHhGRjdDMkQxMiksCiAgICAgIF0sCiAgICAgIGNoaWxkcmVuOiBbCiAgICAgICAgRGFpbHlDaGFsbGVuZ2VIb21lQ2FyZChxdWVzdGlvbkJhbms6IHF1ZXN0aW9uQmFuayksCiAgICAgICAgY29uc3QgUmV0ZW50aW9uSG9tZUNhcmQoKSwKICAgICAgXSwKICAgICk7CiAgfQp9CgpjbGFzcyBDYXJlZXJDZW50ZXJTY3JlZW4gZXh0ZW5kcyBTdGF0ZWxlc3NXaWRnZXQgewogIGNvbnN0IENhcmVlckNlbnRlclNjcmVlbih7c3VwZXIua2V5fSk7CgogIEBvdmVycmlkZQogIFdpZGdldCBidWlsZChCdWlsZENvbnRleHQgY29udGV4dCkgewogICAgcmV0dXJuIF9OYXZpZ2F0aW9uSHViU2NhZmZvbGQoCiAgICAgIHRpdGxlOiAnS2FyaXllcicsCiAgICAgIGVtb2ppOiAn8J+PhicsCiAgICAgIGhlYWRsaW5lOiAnQmlsZ2kgeW9sY3VsdcSfdW51IHRha2lwIGV0JywKICAgICAgc3VidGl0bGU6CiAgICAgICAgICAnU2V2aXllbiwgYmHFn2FyxLFsYXLEsW4sIGF5csSxbnTEsWzEsSBpc3RhdGlzdGlrbGVyaW4gJwogICAgICAgICAgJ3ZlIGHDp3TEscSfxLFuIGtvbGVrc2l5b24gdGVrIHllcmRlLicsCiAgICAgIGNvbG9yczogY29uc3QgWwogICAgICAgIENvbG9yKDB4RkY2RDI4RDkpLAogICAgICAgIENvbG9yKDB4RkY0MzM4Q0EpLAogICAgICBdLAogICAgICBjaGlsZHJlbjogWwogICAgICAgIGNvbnN0IFhwQ2FyZWVyQ2FyZCgpLAogICAgICAgIF9IdWJBY3Rpb25DYXJkKAogICAgICAgICAgZW1vamk6ICfwn5OKJywKICAgICAgICAgIHRpdGxlOiAnxLBzdGF0aXN0aWtsZXIgJiBCYcWfYXLEsW1sYXInLAogICAgICAgICAgZGVzY3JpcHRpb246CiAgICAgICAgICAgICAgJ0RvxJ9ydSBzYXnEsWxhcsSxLCBrYXRlZ29yaSBiYcWfYXLEsWxhcsSxbsSxLCAnCiAgICAgICAgICAgICAgJ3NlcmlsZXJpIHZlIGHDp8SxbGFuIGJhxZ9hcsSxbWxhcsSxIGluY2VsZS4nLAogICAgICAgICAgYWNjZW50OiBjb25zdCBDb2xvcigweEZGN0MzQUVEKSwKICAgICAgICAgIG9uVGFwOiAoKSA9PiBOYXZpZ2F0b3Iub2YoY29udGV4dCkucHVzaCgKICAgICAgICAgICAgTWF0ZXJpYWxQYWdlUm91dGUoCiAgICAgICAgICAgICAgYnVpbGRlcjogKF8pID0+IGNvbnN0IENhcmVlclN0YXRzU2NyZWVuKCksCiAgICAgICAgICAgICksCiAgICAgICAgICApLAogICAgICAgICksCiAgICAgICAgX0h1YkFjdGlvbkNhcmQoCiAgICAgICAgICBlbW9qaTogJ/CfjqgnLAogICAgICAgICAgdGl0bGU6ICdLb2xla3NpeW9uICYgR8O2csO8bsO8bScsCiAgICAgICAgICBkZXNjcmlwdGlvbjoKICAgICAgICAgICAgICAnVGFodGEgdGVtYWxhcsSxbsSxLCBmYXZvcmkgcGl5b251IHZlICcKICAgICAgICAgICAgICAnc2VzIGF0bW9zZmVyaW5pIHNlw6cuJywKICAgICAgICAgIGFjY2VudDogY29uc3QgQ29sb3IoMHhGRjBGNzY2RSksCiAgICAgICAgICBvblRhcDogKCkgPT4gTmF2aWdhdG9yLm9mKGNvbnRleHQpLnB1c2goCiAgICAgICAgICAgIE1hdGVyaWFsUGFnZVJvdXRlKAogICAgICAgICAgICAgIGJ1aWxkZXI6IChfKSA9PiBjb25zdCBDb2xsZWN0aW9uU2NyZWVuKCksCiAgICAgICAgICAgICksCiAgICAgICAgICApLAogICAgICAgICksCiAgICAgIF0sCiAgICApOwogIH0KfQoKY2xhc3MgU2V0dGluZ3NDZW50ZXJTY3JlZW4gZXh0ZW5kcyBTdGF0ZWxlc3NXaWRnZXQgewogIGNvbnN0IFNldHRpbmdzQ2VudGVyU2NyZWVuKHsKICAgIHJlcXVpcmVkIHRoaXMucXVlc3Rpb25CYW5rLAogICAgc3VwZXIua2V5LAogIH0pOwoKICBmaW5hbCBRdWVzdGlvbkJhbmsgcXVlc3Rpb25CYW5rOwoKICBAb3ZlcnJpZGUKICBXaWRnZXQgYnVpbGQoQnVpbGRDb250ZXh0IGNvbnRleHQpIHsKICAgIHJldHVybiBfTmF2aWdhdGlvbkh1YlNjYWZmb2xkKAogICAgICB0aXRsZTogJ0F5YXJsYXInLAogICAgICBlbW9qaTogJ+Kame+4jycsCiAgICAgIGhlYWRsaW5lOiAnT3l1bnUga2VuZGluZSBnw7ZyZSBkw7x6ZW5sZScsCiAgICAgIHN1YnRpdGxlOgogICAgICAgICAgJ1NlcywgZ8O2csO8bsO8bSwgZXJpxZ9pbGViaWxpcmxpaywgam9rZXJsZXIgdmUgJwogICAgICAgICAgJ3Rla25payBhcmHDp2xhciBhcnTEsWsgdGVrIGLDtmzDvG1kZS4nLAogICAgICBjb2xvcnM6IGNvbnN0IFsKICAgICAgICBDb2xvcigweEZGMzM0MTU1KSwKICAgICAgICBDb2xvcigweEZGMEY1NjYxKSwKICAgICAgXSwKICAgICAgY2hpbGRyZW46IFsKICAgICAgICBfSHViQWN0aW9uQ2FyZCgKICAgICAgICAgIGVtb2ppOiAn8J+Rge+4jycsCiAgICAgICAgICB0aXRsZTogJ0dlbmVsIEF5YXJsYXIgJiBFcmnFn2lsZWJpbGlybGlrJywKICAgICAgICAgIGRlc2NyaXB0aW9uOgogICAgICAgICAgICAgICdZYXrEsSBib3l1dHUsIMOnb2N1ayBtb2R1LCBzZXMgc2V2aXllc2ksICcKICAgICAgICAgICAgICAndGl0cmXFn2ltIHZlIGFuaW1hc3lvbiB5b8SfdW5sdcSfdS4nLAogICAgICAgICAgYWNjZW50OiBjb25zdCBDb2xvcigweEZGMTU1RTc1KSwKICAgICAgICAgIG9uVGFwOiAoKSA9PiBOYXZpZ2F0b3Iub2YoY29udGV4dCkucHVzaCgKICAgICAgICAgICAgTWF0ZXJpYWxQYWdlUm91dGUoCiAgICAgICAgICAgICAgYnVpbGRlcjogKF8pID0+CiAgICAgICAgICAgICAgICAgIGNvbnN0IEFjY2Vzc2liaWxpdHlTZXR0aW5nc1NjcmVlbigpLAogICAgICAgICAgICApLAogICAgICAgICAgKSwKICAgICAgICApLAogICAgICAgIF9IdWJBY3Rpb25DYXJkKAogICAgICAgICAgZW1vamk6ICfwn46BJywKICAgICAgICAgIHRpdGxlOiAnQ2FubMSxIE95dW4sIEpva2VybGVyICYgUmlzaycsCiAgICAgICAgICBkZXNjcmlwdGlvbjoKICAgICAgICAgICAgICAnWFAgZWZla3RsZXJpbmksIGpva2VybGVyaSB2ZSByaXNrbGkgJwogICAgICAgICAgICAgICdzb3J1IHNlw6dlbmXEn2luaSB5w7ZuZXQuJywKICAgICAgICAgIGFjY2VudDogY29uc3QgQ29sb3IoMHhGRjdDM0FFRCksCiAgICAgICAgICBvblRhcDogKCkgPT4gTmF2aWdhdG9yLm9mKGNvbnRleHQpLnB1c2goCiAgICAgICAgICAgIE1hdGVyaWFsUGFnZVJvdXRlKAogICAgICAgICAgICAgIGJ1aWxkZXI6IChfKSA9PgogICAgICAgICAgICAgICAgICBjb25zdCBHYW1lcGxheUJvb3N0U2V0dGluZ3NTY3JlZW4oKSwKICAgICAgICAgICAgKSwKICAgICAgICAgICksCiAgICAgICAgKSwKICAgICAgICBfSHViQWN0aW9uQ2FyZCgKICAgICAgICAgIGVtb2ppOiAn8J+OqCcsCiAgICAgICAgICB0aXRsZTogJ1RlbWEsIFBpeW9uICYgU2VzIEF0bW9zZmVyaScsCiAgICAgICAgICBkZXNjcmlwdGlvbjoKICAgICAgICAgICAgICAnS29sZWtzaXlvbmRha2kgZ8O2csO8bsO8bWxlcmkgdmUgZmF2b3JpICcKICAgICAgICAgICAgICAnb3l1biBwYXLDp2FsYXLEsW7EsSBkZcSfacWfdGlyLicsCiAgICAgICAgICBhY2NlbnQ6IGNvbnN0IENvbG9yKDB4RkZCNDUzMDkpLAogICAgICAgICAgb25UYXA6ICgpID0+IE5hdmlnYXRvci5vZihjb250ZXh0KS5wdXNoKAogICAgICAgICAgICBNYXRlcmlhbFBhZ2VSb3V0ZSgKICAgICAgICAgICAgICBidWlsZGVyOiAoXykgPT4gY29uc3QgQ29sbGVjdGlvblNjcmVlbigpLAogICAgICAgICAgICApLAogICAgICAgICAgKSwKICAgICAgICApLAogICAgICAgIF9IdWJBY3Rpb25DYXJkKAogICAgICAgICAgZW1vamk6ICfwn5uh77iPJywKICAgICAgICAgIHRpdGxlOiAnU2lzdGVtIFNhxJ9sxLHEn8SxICYgVGVrbmlrIEtvbnRyb2wnLAogICAgICAgICAgZGVzY3JpcHRpb246CiAgICAgICAgICAgICAgJ0thecSxdCB5ZWRlxJ9pbmksIHNvcnUgYmFua2FzxLFuxLEgdmUgJwogICAgICAgICAgICAgICd0ZWtuaWsgaGF0YSBnw7xubMO8xJ/DvG7DvCBrb250cm9sIGV0LicsCiAgICAgICAgICBhY2NlbnQ6IGNvbnN0IENvbG9yKDB4RkYwNDc4NTcpLAogICAgICAgICAgb25UYXA6ICgpID0+IE5hdmlnYXRvci5vZihjb250ZXh0KS5wdXNoKAogICAgICAgICAgICBNYXRlcmlhbFBhZ2VSb3V0ZSgKICAgICAgICAgICAgICBidWlsZGVyOiAoXykgPT4gU3lzdGVtSGVhbHRoU2NyZWVuKAogICAgICAgICAgICAgICAgcXVlc3Rpb25CYW5rOiBxdWVzdGlvbkJhbmssCiAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgKSwKICAgICAgICAgICksCiAgICAgICAgKSwKICAgICAgICBfSHViQWN0aW9uQ2FyZCgKICAgICAgICAgIGVtb2ppOiAn8J+TmCcsCiAgICAgICAgICB0aXRsZTogJ0XEn2l0aW1pIFllbmlkZW4gR8O2c3RlcicsCiAgICAgICAgICBkZXNjcmlwdGlvbjoKICAgICAgICAgICAgICAnWmFyLCByb3RhLCByb3pldCB2ZSDDtnplbCBhbGFubGFyxLEgYW5sYXRhbiAnCiAgICAgICAgICAgICAgJ2vEsXNhIGXEn2l0aW1pIHRla3JhciBhw6cuJywKICAgICAgICAgIGFjY2VudDogY29uc3QgQ29sb3IoMHhGRjI1NjNFQiksCiAgICAgICAgICBvblRhcDogKCkgewogICAgICAgICAgICB1bmF3YWl0ZWQoCiAgICAgICAgICAgICAgRmlyc3RSdW5UdXRvcmlhbC5zaG93KAogICAgICAgICAgICAgICAgY29udGV4dCwKICAgICAgICAgICAgICAgIGZvcmNlOiB0cnVlLAogICAgICAgICAgICAgICksCiAgICAgICAgICAgICk7CiAgICAgICAgICB9LAogICAgICAgICksCiAgICAgIF0sCiAgICApOwogIH0KfQoKY2xhc3MgX05hdmlnYXRpb25IdWJTY2FmZm9sZCBleHRlbmRzIFN0YXRlbGVzc1dpZGdldCB7CiAgY29uc3QgX05hdmlnYXRpb25IdWJTY2FmZm9sZCh7CiAgICByZXF1aXJlZCB0aGlzLnRpdGxlLAogICAgcmVxdWlyZWQgdGhpcy5lbW9qaSwKICAgIHJlcXVpcmVkIHRoaXMuaGVhZGxpbmUsCiAgICByZXF1aXJlZCB0aGlzLnN1YnRpdGxlLAogICAgcmVxdWlyZWQgdGhpcy5jb2xvcnMsCiAgICByZXF1aXJlZCB0aGlzLmNoaWxkcmVuLAogIH0pOwoKICBmaW5hbCBTdHJpbmcgdGl0bGU7CiAgZmluYWwgU3RyaW5nIGVtb2ppOwogIGZpbmFsIFN0cmluZyBoZWFkbGluZTsKICBmaW5hbCBTdHJpbmcgc3VidGl0bGU7CiAgZmluYWwgTGlzdDxDb2xvcj4gY29sb3JzOwogIGZpbmFsIExpc3Q8V2lkZ2V0PiBjaGlsZHJlbjsKCiAgQG92ZXJyaWRlCiAgV2lkZ2V0IGJ1aWxkKEJ1aWxkQ29udGV4dCBjb250ZXh0KSB7CiAgICByZXR1cm4gU2NhZmZvbGQoCiAgICAgIGFwcEJhcjogQXBwQmFyKHRpdGxlOiBUZXh0KHRpdGxlKSksCiAgICAgIGJvZHk6IENvbnRhaW5lcigKICAgICAgICBkZWNvcmF0aW9uOiBjb25zdCBCb3hEZWNvcmF0aW9uKAogICAgICAgICAgZ3JhZGllbnQ6IExpbmVhckdyYWRpZW50KAogICAgICAgICAgICBiZWdpbjogQWxpZ25tZW50LnRvcExlZnQsCiAgICAgICAgICAgIGVuZDogQWxpZ25tZW50LmJvdHRvbVJpZ2h0LAogICAgICAgICAgICBjb2xvcnM6IFsKICAgICAgICAgICAgICBDb2xvcigweEZGRjhGQUZDKSwKICAgICAgICAgICAgICBDb2xvcigweEZGRURFOUZFKSwKICAgICAgICAgICAgXSwKICAgICAgICAgICksCiAgICAgICAgKSwKICAgICAgICBjaGlsZDogU2FmZUFyZWEoCiAgICAgICAgICBjaGlsZDogTGlzdFZpZXcoCiAgICAgICAgICAgIHBhZGRpbmc6IGNvbnN0IEVkZ2VJbnNldHMuZnJvbUxUUkIoCiAgICAgICAgICAgICAgMTgsCiAgICAgICAgICAgICAgMTYsCiAgICAgICAgICAgICAgMTgsCiAgICAgICAgICAgICAgMjgsCiAgICAgICAgICAgICksCiAgICAgICAgICAgIGNoaWxkcmVuOiBbCiAgICAgICAgICAgICAgQ29udGFpbmVyKAogICAgICAgICAgICAgICAgcGFkZGluZzogY29uc3QgRWRnZUluc2V0cy5hbGwoMjIpLAogICAgICAgICAgICAgICAgZGVjb3JhdGlvbjogQm94RGVjb3JhdGlvbigKICAgICAgICAgICAgICAgICAgZ3JhZGllbnQ6IExpbmVhckdyYWRpZW50KGNvbG9yczogY29sb3JzKSwKICAgICAgICAgICAgICAgICAgYm9yZGVyUmFkaXVzOiBCb3JkZXJSYWRpdXMuY2lyY3VsYXIoMjgpLAogICAgICAgICAgICAgICAgICBib3hTaGFkb3c6IGNvbnN0IFsKICAgICAgICAgICAgICAgICAgICBCb3hTaGFkb3coCiAgICAgICAgICAgICAgICAgICAgICBjb2xvcjogQ29sb3IoMHgzMzAwMDAwMCksCiAgICAgICAgICAgICAgICAgICAgICBibHVyUmFkaXVzOiAxNCwKICAgICAgICAgICAgICAgICAgICAgIG9mZnNldDogT2Zmc2V0KDAsIDcpLAogICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgIF0sCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgY2hpbGQ6IENvbHVtbigKICAgICAgICAgICAgICAgICAgY2hpbGRyZW46IFsKICAgICAgICAgICAgICAgICAgICBUZXh0KAogICAgICAgICAgICAgICAgICAgICAgZW1vamksCiAgICAgICAgICAgICAgICAgICAgICBzdHlsZTogY29uc3QgVGV4dFN0eWxlKGZvbnRTaXplOiA1NCksCiAgICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgICBjb25zdCBTaXplZEJveChoZWlnaHQ6IDgpLAogICAgICAgICAgICAgICAgICAgIFRleHQoCiAgICAgICAgICAgICAgICAgICAgICBoZWFkbGluZSwKICAgICAgICAgICAgICAgICAgICAgIHRleHRBbGlnbjogVGV4dEFsaWduLmNlbnRlciwKICAgICAgICAgICAgICAgICAgICAgIHN0eWxlOiBjb25zdCBUZXh0U3R5bGUoCiAgICAgICAgICAgICAgICAgICAgICAgIGNvbG9yOiBDb2xvcnMud2hpdGUsCiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAyNCwKICAgICAgICAgICAgICAgICAgICAgICAgZm9udFdlaWdodDogRm9udFdlaWdodC53OTAwLAogICAgICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgICAgIGNvbnN0IFNpemVkQm94KGhlaWdodDogNyksCiAgICAgICAgICAgICAgICAgICAgVGV4dCgKICAgICAgICAgICAgICAgICAgICAgIHN1YnRpdGxlLAogICAgICAgICAgICAgICAgICAgICAgdGV4dEFsaWduOiBUZXh0QWxpZ24uY2VudGVyLAogICAgICAgICAgICAgICAgICAgICAgc3R5bGU6IGNvbnN0IFRleHRTdHlsZSgKICAgICAgICAgICAgICAgICAgICAgICAgY29sb3I6IENvbG9yKDB4RkZFN0UxRjApLAogICAgICAgICAgICAgICAgICAgICAgICBoZWlnaHQ6IDEuMzUsCiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRXZWlnaHQ6IEZvbnRXZWlnaHQudzYwMCwKICAgICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgICAgXSwKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICBjb25zdCBTaXplZEJveChoZWlnaHQ6IDE2KSwKICAgICAgICAgICAgICBmb3IgKHZhciBpbmRleCA9IDA7CiAgICAgICAgICAgICAgICAgIGluZGV4IDwgY2hpbGRyZW4ubGVuZ3RoOwogICAgICAgICAgICAgICAgICBpbmRleCsrKSAuLi5bCiAgICAgICAgICAgICAgICBjaGlsZHJlbltpbmRleF0sCiAgICAgICAgICAgICAgICBpZiAoaW5kZXggPCBjaGlsZHJlbi5sZW5ndGggLSAxKQogICAgICAgICAgICAgICAgICBjb25zdCBTaXplZEJveChoZWlnaHQ6IDExKSwKICAgICAgICAgICAgICBdLAogICAgICAgICAgICBdLAogICAgICAgICAgKSwKICAgICAgICApLAogICAgICApLAogICAgKTsKICB9Cn0KCmNsYXNzIF9IdWJBY3Rpb25DYXJkIGV4dGVuZHMgU3RhdGVsZXNzV2lkZ2V0IHsKICBjb25zdCBfSHViQWN0aW9uQ2FyZCh7CiAgICByZXF1aXJlZCB0aGlzLmVtb2ppLAogICAgcmVxdWlyZWQgdGhpcy50aXRsZSwKICAgIHJlcXVpcmVkIHRoaXMuZGVzY3JpcHRpb24sCiAgICByZXF1aXJlZCB0aGlzLmFjY2VudCwKICAgIHJlcXVpcmVkIHRoaXMub25UYXAsCiAgfSk7CgogIGZpbmFsIFN0cmluZyBlbW9qaTsKICBmaW5hbCBTdHJpbmcgdGl0bGU7CiAgZmluYWwgU3RyaW5nIGRlc2NyaXB0aW9uOwogIGZpbmFsIENvbG9yIGFjY2VudDsKICBmaW5hbCBWb2lkQ2FsbGJhY2sgb25UYXA7CgogIEBvdmVycmlkZQogIFdpZGdldCBidWlsZChCdWlsZENvbnRleHQgY29udGV4dCkgewogICAgcmV0dXJuIENhcmQoCiAgICAgIG1hcmdpbjogRWRnZUluc2V0cy56ZXJvLAogICAgICBjbGlwQmVoYXZpb3I6IENsaXAuYW50aUFsaWFzLAogICAgICBjaGlsZDogSW5rV2VsbCgKICAgICAgICBvblRhcDogb25UYXAsCiAgICAgICAgY2hpbGQ6IFBhZGRpbmcoCiAgICAgICAgICBwYWRkaW5nOiBjb25zdCBFZGdlSW5zZXRzLmFsbCgxNiksCiAgICAgICAgICBjaGlsZDogUm93KAogICAgICAgICAgICBjaGlsZHJlbjogWwogICAgICAgICAgICAgIENvbnRhaW5lcigKICAgICAgICAgICAgICAgIHdpZHRoOiA1NCwKICAgICAgICAgICAgICAgIGhlaWdodDogNTQsCiAgICAgICAgICAgICAgICBhbGlnbm1lbnQ6IEFsaWdubWVudC5jZW50ZXIsCiAgICAgICAgICAgICAgICBkZWNvcmF0aW9uOiBCb3hEZWNvcmF0aW9uKAogICAgICAgICAgICAgICAgICBjb2xvcjogYWNjZW50LndpdGhWYWx1ZXMoYWxwaGE6IDAuMTMpLAogICAgICAgICAgICAgICAgICBib3JkZXJSYWRpdXM6IEJvcmRlclJhZGl1cy5jaXJjdWxhcigxNiksCiAgICAgICAgICAgICAgICAgIGJvcmRlcjogQm9yZGVyLmFsbCgKICAgICAgICAgICAgICAgICAgICBjb2xvcjogYWNjZW50LndpdGhWYWx1ZXMoYWxwaGE6IDAuMzUpLAogICAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgIGNoaWxkOiBUZXh0KAogICAgICAgICAgICAgICAgICBlbW9qaSwKICAgICAgICAgICAgICAgICAgc3R5bGU6IGNvbnN0IFRleHRTdHlsZShmb250U2l6ZTogMjkpLAogICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICApLAogICAgICAgICAgICAgIGNvbnN0IFNpemVkQm94KHdpZHRoOiAxMyksCiAgICAgICAgICAgICAgRXhwYW5kZWQoCiAgICAgICAgICAgICAgICBjaGlsZDogQ29sdW1uKAogICAgICAgICAgICAgICAgICBjcm9zc0F4aXNBbGlnbm1lbnQ6CiAgICAgICAgICAgICAgICAgICAgICBDcm9zc0F4aXNBbGlnbm1lbnQuc3RhcnQsCiAgICAgICAgICAgICAgICAgIGNoaWxkcmVuOiBbCiAgICAgICAgICAgICAgICAgICAgVGV4dCgKICAgICAgICAgICAgICAgICAgICAgIHRpdGxlLAogICAgICAgICAgICAgICAgICAgICAgc3R5bGU6IGNvbnN0IFRleHRTdHlsZSgKICAgICAgICAgICAgICAgICAgICAgICAgZm9udFNpemU6IDE3LAogICAgICAgICAgICAgICAgICAgICAgICBmb250V2VpZ2h0OiBGb250V2VpZ2h0Lnc5MDAsCiAgICAgICAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgICAgY29uc3QgU2l6ZWRCb3goaGVpZ2h0OiA0KSwKICAgICAgICAgICAgICAgICAgICBUZXh0KAogICAgICAgICAgICAgICAgICAgICAgZGVzY3JpcHRpb24sCiAgICAgICAgICAgICAgICAgICAgICBzdHlsZTogY29uc3QgVGV4dFN0eWxlKAogICAgICAgICAgICAgICAgICAgICAgICBjb2xvcjogQ29sb3IoMHhGRjY0NzQ4QiksCiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAxMiwKICAgICAgICAgICAgICAgICAgICAgICAgaGVpZ2h0OiAxLjMsCiAgICAgICAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAgIF0sCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgY29uc3QgU2l6ZWRCb3god2lkdGg6IDcpLAogICAgICAgICAgICAgIEljb24oCiAgICAgICAgICAgICAgICBJY29ucy5jaGV2cm9uX3JpZ2h0X3JvdW5kZWQsCiAgICAgICAgICAgICAgICBjb2xvcjogYWNjZW50LAogICAgICAgICAgICAgICksCiAgICAgICAgICAgIF0sCiAgICAgICAgICApLAogICAgICAgICksCiAgICAgICksCiAgICApOwogIH0KfQo="""

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

if "part 'main_navigation.dart';" in main or TARGET.exists():
    raise SystemExit(
        "Yeni ana menü ve navigasyon sistemi zaten kurulmuş görünüyor."
    )

required_main = [
    "part 'question_quality.dart';",
    "class _HomeScreenState",
    "_buildHeroHeader(),",
    "_buildNewGameCard(),",
    "DailyChallengeHomeCard(",
    "const RetentionHomeCard(),",
    "SocialHomeButton(",
    "Bilgi Rotası • Sürüm 1.31.0",
]

for marker in required_main:
    if marker not in main:
        raise SystemExit(
            f"Beklenen main.dart bölümü bulunamadı: {marker}"
        )

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)

if version_match is None:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, version_match.groups())

if (major, minor, patch, build) != (1, 31, 0, 41):
    raise SystemExit(
        "Bu paket 1.31.0+41 sürümü için hazırlandı.\n"
        f"Depodaki sürüm: {major}.{minor}.{patch}+{build}"
    )

new_version = "1.32.0+42"

backup_dir = Path(tempfile.mkdtemp(
    prefix="bilgi_rotasi_main_navigation_"
))
committed = False

try:
    shutil.copy2(MAIN, backup_dir / "main.dart")
    shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")
    shutil.copy2(TEST, backup_dir / "system_smoke_test.dart")

    TARGET.write_text(
        base64.b64decode(NAVIGATION_B64).decode("utf-8"),
        encoding="utf-8",
    )

    main = main.replace(
        "part 'question_quality.dart';",
        "part 'question_quality.dart';\n"
        "part 'main_navigation.dart';",
        1,
    )

    home_state = main.index("class _HomeScreenState")
    children_start = main.index(
        "              children: [\n"
        "                _buildHeroHeader(),",
        home_state,
    )
    version_position = main.index(
        "'Bilgi Rotası • Sürüm 1.31.0'",
        children_start,
    )
    children_end = main.index(
        "              ],\n"
        "            ),",
        version_position,
    )

    new_children = """              children: [
                _buildHeroHeader(),
                const SizedBox(height: 18),
                _buildNewGameCard(),
                const SizedBox(height: 14),
                FutureBuilder<SavedGame?>(
                  future: _savedGameFuture,
                  builder: (context, snapshot) {
                    final savedGame = snapshot.data;

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingCard();
                    }

                    if (savedGame == null) {
                      return const SizedBox.shrink();
                    }

                    return _buildSavedGameCard(savedGame);
                  },
                ),
                const SizedBox(height: 16),
                DailyChallengeHomeCard(
                  questionBank: widget.questionBank,
                ),
                const SizedBox(height: 18),
                const Text(
                  'BÖLÜMLER',
                  style: TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 13,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                MainNavigationGrid(
                  questionBank: widget.questionBank,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bilgi Rotası • Sürüm 1.32.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
"""

    main = main[:children_start] + new_children + main[children_end:]

    for old, new in {
        "'Yeni bir bilgi düellosu başlat'": "'OYUNA BAŞLA'",
        "'Yeni Oyun Kur'": "'Standart Tahta Oyununu Başlat'",
    }.items():
        if old not in main:
            raise RuntimeError(
                f"Ana oyun kartı metni bulunamadı: {old}"
            )
        main = main.replace(old, new, 1)

    pubspec = re.sub(
        r"^version:\s*.*$",
        f"version: {new_version}",
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )

    test_insert = """
    test('Ana navigasyonda beş bölüm bulunur', () {
      expect(MainNavigationSection.values.length, 5);
      expect(
        MainNavigationSection.values
            .map((section) => section.title)
            .toSet()
            .length,
        5,
      );
    });
"""

    group_end = test.rfind("  });\n}")

    if group_end < 0:
        raise RuntimeError(
            "Test dosyası ekleme noktası bulunamadı."
        )

    test = test[:group_end] + test_insert + test[group_end:]

    MAIN.write_text(main, encoding="utf-8")
    PUBSPEC.write_text(pubspec, encoding="utf-8")
    TEST.write_text(test, encoding="utf-8")

    checks = {
        MAIN: [
            "part 'main_navigation.dart';",
            "MainNavigationGrid(",
            "'BÖLÜMLER'",
            "'OYUNA BAŞLA'",
            "Bilgi Rotası • Sürüm 1.32.0",
        ],
        TARGET: [
            "enum MainNavigationSection",
            "class MainNavigationGrid",
            "class PlayCenterScreen",
            "class DailyCenterScreen",
            "class CareerCenterScreen",
            "class SettingsCenterScreen",
            "Standart Tahta Oyunu",
            "Sistem Sağlığı & Teknik Kontrol",
        ],
        TEST: ["Ana navigasyonda beş bölüm bulunur"],
        PUBSPEC: [f"version: {new_version}"],
    }

    for path, markers in checks.items():
        content = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in content:
                raise RuntimeError(
                    f"Kurulum doğrulaması başarısız: "
                    f"{path} / {marker}"
                )

    if shutil.which("dart"):
        run([
            "dart",
            "format",
            "lib/main.dart",
            "lib/main_navigation.dart",
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
        "lib/main_navigation.dart",
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
        raise RuntimeError(
            "Commit edilecek değişiklik bulunamadı."
        )

    run([
        "git",
        "commit",
        "-m",
        "Ana menuyu bes bolumlu navigasyona donustur",
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
            "lib/main_navigation.dart",
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
            subprocess.run(
                ["flutter", "pub", "get"],
                check=False,
            )

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
print("✅ Ana menü sadeleştirildi.")
print("✅ Büyük OYUNA BAŞLA kartı korundu.")
print("✅ Günlük görev özeti ana ekranda bırakıldı.")
print("✅ Oyna, Günlük, Kariyer, Sosyal ve Ayarlar bölümleri eklendi.")
print("✅ Oyun modları Oyna merkezinde toplandı.")
print("✅ XP, istatistik ve koleksiyon Kariyer merkezinde toplandı.")
print("✅ Ses, erişilebilirlik ve teknik araçlar Ayarlar merkezinde toplandı.")
print("✅ Devam eden oyun kartı korunarak ana ekran kalabalığı azaltıldı.")
print("✅ Yeni otomatik navigasyon testi eklendi.")
print("✅ questions.json dosyasına dokunulmadı.")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub main dalına gönderildi.")
