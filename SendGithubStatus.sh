set -e

# Token PipelineName PipelineNum StageName StageNum Status

if [ $# -ne 6 ] && [ $# -ne 1 ] ; then
    echo "Invalid number of arguments"
    exit 1
fi

# Get Hash
COMMIT_HASH=$(cat ./.githash)

# Get details
if [ $# -eq 6 ] ; then
    PIPELINE_NAME=$2
    PIPELINE_NUM=$3
    STAGE_NAME=$4
    STAGE_NUM=$5
else
    PIPELINE_NAME=$(cat ./.pipeline_name)
    PIPELINE_NUM=$(cat ./.pipeline_num)
    STAGE_NAME=$(cat ./.stage_name)
    STAGE_NUM=$(cat ./.stage_num)
fi

# Get target branch for Owner and Repo
PR_OWNER=$(cat ./.pr_owner)
PR_REPO=$(cat ./.pr_repo)

SEND_STATUS=$6

echo "COMMIT_HASH: $COMMIT_HASH"
echo "PIPELINE_NAME: $PIPELINE_NAME"
echo "PIPELINE_NUM: $PIPELINE_NUM"
echo "STAGE_NAME: $STAGE_NAME"
echo "STAGE_NUM: $STAGE_NUM"
echo "PR_OWNER: $PR_OWNER"
echo "PR_REPO: $PR_REPO"


curl -L --fail-with-body \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $1" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$PR_OWNER/$PR_REPO/statuses/$COMMIT_HASH \
    -d \
    "{
        \"context\": \"Stage $STAGE_NAME for pipeline $PIPELINE_NAME\",
        \"target_url\": \"https://ci.nekoboxcoder.dev/go/pipelines/$PIPELINE_NAME/$PIPELINE_NUM/$STAGE_NAME/$STAGE_NUM\",
        \"state\": \"$SEND_STATUS\"
    }"
