if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )

firebase deploy --project junction2020-prod --only hosting
pause