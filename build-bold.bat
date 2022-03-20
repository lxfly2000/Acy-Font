if not exist afdko_env (
	py -m venv afdko_env
	call afdko_env\Scripts\activate.bat
	py -m pip install afdko
) else (
	call afdko_env\Scripts\activate.bat
)
if exist Bold\Acy-Bold.otf del Bold\Acy-Bold.otf
if not exist Bold md Bold
makeotf -f Acy-Bold.otf -ff Adobe-GB1\GSUB\ag15-gsub.fea -fi fontinfo-bold.txt -r -nS -o Bold\Acy-Bold.otf
ttx -f Bold\Acy-Bold.otf
notepad Bold\Acy-Bold.ttx
ttx -f Bold\Acy-Bold.ttx
