# run this script in the git repo you want to analyze.
# gitstats "author1 author2" "branch1 branch2" "some-date"
# third argument passed to git log --after and may be omitted for commits from all time.

# example: ./gitstats.sh "mjdiloreto Matthew" "develop 2.0-webclient"
# Gives stats for all commits by mjdiloreto and Matthew (2 accounts) for branch develop and 2.0-webclient for all time.

# example ./gitstats.sh "dwalend David" "develop" "2019-07-04 00:00:00"
# Gives stats for all commits by dwalend and David for branch develop since July 4. 2019.

authors=$1
branches=$2
if [ -n "$3" ]; then 
	after=$3
else 
	after=""
fi
output_file="/tmp/gitstats.txt"

rm $output_file
git stash
for branch in $branches ; do
	git checkout $branch
	git pull origin $branch
  for author in $authors ; do 
  	if [ -n "$after" ] ; then 
			git log --pretty="@%h" --after=$after --shortstat --author=$author | tr "\n" " " | tr "@" "\n" >> $output_file
		else
			git log --pretty="@%h" --shortstat --author=$author | tr "\n" " " | tr "@" "\n" >> $output_file
		fi
	done
	git checkout -
done
git stash pop

cat $output_file | sed 's/ insertions(+)//g' | sed 's/ insertion(+)//g' | sed 's/ deletions(-)//g' | sed 's/ deletion(-)//g' | sed  's/ files changed//g' | sed 's/ file changed//g' | sed 's/,//g' | tr -s " " | sort -u -k1,1 > $output_file 

cat $output_file | awk '{s+=$2}END{print s" files changed"}'
cat $output_file | awk '{s+=$3}END{print s" insertions(+)"}'
cat $output_file | awk '{s+=$4}END{print s" deletions(-)"}'

rm $output_file

