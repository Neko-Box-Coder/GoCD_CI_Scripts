REM @echo off
setlocal enabledelayedexpansion

REM Token Status [PipelineName] [PipelineNum] [StageName] [StageNum] [JobName]

set argC=0
for %%x in (%*) do Set /A argC+=1

if not %argC%==7 if not %argC%==2 (
    echo "Invalid number of arguments"
    exit /b 1
) else (
    goto :getdetails
)

:getdetails
REM Get Hash
for /f %%i in (.\.githash) do set "COMMIT_HASH=%%i"

REM Get details
if %argC%==7 (
    set "PIPELINE_NAME=%3"
    set "PIPELINE_NUM=%4"
    set "STAGE_NAME=%5"
    set "STAGE_NUM=%6"
    set "JOB_NAME=%7"
) else (
    for /f %%j in (.\.pipeline_name) do set "PIPELINE_NAME=%%j"
    for /f %%j in (.\.pipeline_num) do set "PIPELINE_NUM=%%j"
    for /f %%j in (.\.stage_name) do set "STAGE_NAME=%%j"
    for /f %%j in (.\.stage_num) do set "STAGE_NUM=%%j"
    for /f %%j in (.\.job_name) do set "JOB_NAME=%%j"
)

REM Get target branch for Owner and Repo
for /f %%k in (.\.repo_owner) do set "REPO_OWNER=%%k"
for /f %%k in (.\.repo_name) do set "REPO_NAME=%%k"

set "SEND_STATUS=%2"

echo "COMMIT_HASH: %COMMIT_HASH%"
echo "PIPELINE_NAME: %PIPELINE_NAME%"
echo "PIPELINE_NUM: %PIPELINE_NUM%"
echo "STAGE_NAME: %STAGE_NAME%"
echo "STAGE_NUM: %STAGE_NUM%"
echo "REPO_OWNER: %REPO_OWNER%"
echo "REPO_NAME: %REPO_NAME%"

curl -L --fail-with-body ^
    -X POST ^
    -H "Accept: application/vnd.github+json" ^
    -H "Authorization: Bearer %1" ^
    -H "X-GitHub-Api-Version: 2022-11-28" ^
    https://api.github.com/repos/%REPO_OWNER%/%REPO_NAME%/statuses/%COMMIT_HASH% ^
    -d ^
    ^"{ ^
        \"context\": \"Job !JOB_NAME! in stage !STAGE_NAME! for pipeline !PIPELINE_NAME!\", ^
        \"target_url\": \"https://ci.nekoboxcoder.dev/go/tab/build/detail/!PIPELINE_NAME!/!PIPELINE_NUM!/!STAGE_NAME!/!STAGE_NUM!/!JOB_NAME!\", ^
        \"state\": \"%SEND_STATUS%\" ^
    }^"
