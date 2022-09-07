#!/bin/zsh
FILE="list_instances.txt"
FILE_FINAL="final.txt"
FILE_PLATFORM="platform_result.txt"

files=($FILE $FILE_FINAL $FILE_PLATFORM)

for file in $files
do
touch $file
done


while read tt
do
    yc compute instance list --folder-id=$tt | awk '{print $2}' | grep "^[a-z0-9]\{20\}$" &>> $FILE
done < folders_list.txt


for line in $(cat $FILE); do
    echo "Instance ID: $line" &>> $FILE_FINAL
    #yc compute instance get --id=$line | head -n 1 &>> $FILE_FINAL
    yc compute instance get --id=$line | grep "platform_id" &>> $FILE_FINAL
    yc compute instance get --id=$line | grep -A2 "resources:" &>> $FILE_FINAL
    echo "----------------------------------"  &>> $FILE_FINAL
done

echo "Количество ВМ в облаке на платформе Intel Cascade Lake: $(cat $FILE_FINAL | grep "standard-v2" | wc -l)" &>> $FILE_PLATFORM
echo "Количество ВМ в облаке на платформе Intel Ice Lake: $(cat $FILE_FINAL | grep "standard-v3" | wc -l)" &>> $FILE_PLATFORM

# Creating zip-archive and deleting old files
for file in $files
do
zip resources.zip $file
rm $file
done

zip resources.zip folders_list.txt
rm folders_list.txt
