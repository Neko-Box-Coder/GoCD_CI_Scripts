REM @echo off
setlocal enabledelayedexpansion

REM Token PipelineName PipelineNum StageName StageNum Status

if "%~6"=="" if not "%~1"=="" (
    goto :getdetails
) else (
    echo "Invalid number of arguments"
    exit /b 1
)

:getdetails
REM Get Hash
for /f %%i in (.\.githash) do set "COMMIT_HASH=%%i"

REM Get details
if not "%~6"=="" (
    set "PIPELINE_NAME=%2"
    set "PIPELINE_NUM=%3"
    set "STAGE_NAME=%4"
    set "STAGE_NUM=%5"
) else (
    for /f %%j in (.\.pipeline_name) do set "PIPELINE_NAME=%%j"
    for /f %%j in (.\.pipeline_num) do set "PIPELINE_NUM=%%j"
    for /f %%j in (.\.stage_name) do set "STAGE_NAME=%%j"
    for /f %%j in (.\.stage_num) do set "STAGE_NUM=%%j"
)

REM Get target branch for Owner and Repo
for /f %%k in (.\.pr_owner) do set "PR_OWNER=%%k"
for /f %%k in (.\.pr_repo) do set "PR_REPO=%%k"

set "SEND_STATUS=%6"

curl -L --fail-with-body ^
    -X POST ^
    -H "Accept: application/vnd.github+json" ^
    -H "Authorization: Bearer %1" ^
    -H "X-GitHub-Api-Version: 2022-11-28" ^
    https://api.github.com/repos/%PR_OWNER%/%PR_REPO%/statuses/%COMMIT_HASH% ^
    -d ^
    ^"{ ^
        \"context\": \"Stage !STAGE_NAME! for pipeline !PIPELINE_NAME!\", ^
        \"target_url\": \"https://ci.nekoboxcoder.dev/go/pipelines/!PIPELINE_NAME!/!PIPELINE_NUM!/!STAGE_NAME!/!STAGE_NUM!\", ^
        \"state\": \"%SEND_STATUS%\" ^
    }^"
