set -e

# Token Status [PipelineName] [PipelineNum] [StageName] [StageNum] [JobName]

if [ $# -ne 7 ] && [ $# -ne 2 ] ; then
    echo "Invalid number of arguments"
    exit 1
fi

# Get Hash
COMMIT_HASH=$(cat ./.githash)

# Get details
if [ $# -eq 7 ] ; then
    PIPELINE_NAME=$3
    PIPELINE_NUM=$4
    STAGE_NAME=$5
    STAGE_NUM=$6
    JOB_NAME=$7
else
    PIPELINE_NAME=$(cat ./.pipeline_name)
    PIPELINE_NUM=$(cat ./.pipeline_num)
    STAGE_NAME=$(cat ./.stage_name)
    STAGE_NUM=$(cat ./.stage_num)
    JOB_NAME=$(cat ./.job_name)
fi

# Get target branch for Owner and Repo
REPO_OWNER=$(cat ./.repo_owner)
REPO_NAME=$(cat ./.repo_name)

SEND_STATUS=$2

echo "COMMIT_HASH: $COMMIT_HASH"
echo "PIPELINE_NAME: $PIPELINE_NAME"
echo "PIPELINE_NUM: $PIPELINE_NUM"
echo "STAGE_NAME: $STAGE_NAME"
echo "STAGE_NUM: $STAGE_NUM"
echo "JOB_NAME: $JOB_NAME"
echo "REPO_OWNER: $REPO_OWNER"
echo "REPO_NAME: $REPO_NAME"


curl -L --fail-with-body \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $1" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/statuses/$COMMIT_HASH \
    -d \
    "{
        \"context\": \"Job $JOB_NAME in stage $STAGE_NAME for pipeline $PIPELINE_NAME\",
        \"target_url\": \"https://ci.nekoboxcoder.dev/go/pipelines/$PIPELINE_NAME/$PIPELINE_NUM/$STAGE_NAME/$STAGE_NUM/$JOB_NAME\",
        \"state\": \"$SEND_STATUS\"
    }"
