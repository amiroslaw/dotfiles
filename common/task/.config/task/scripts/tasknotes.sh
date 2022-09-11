#!/bin/sh

# tworzenie notatek do zadań 
# na podstawie uuid tworzy pliki tekstowe, jako referencja do zadania
# do hooka można dodać automatyczne tworzeni i usuwanie
# dodać adnotacje

location="/home/$(whoami)/.config/task/notes"
mkdir -p "$location"
[ -e "$location" ] || mkdir "$location"

[ "$1" = "show" ] && {
	{ tu="$(task "$2" uuids)" || echo "Input a task number" ; }
	{
		[ -e "$location"/"$tu" ] && cat "$location"/"$tu" && exit 0 
	} || \
		{
		echo "No notes" 
		exit 1 
	}
}

[ "$1" = "rm" ] && {
	{ tu="$(task "$2" uuids)" || echo "Input a task number" ; }
	{
		[ -e "$location/$tu" ] && rm "$location/$tu" && exit 0 
	} || \
		{
		echo "No notes" 
		exit 1 
	}
}

tu="$(task "$1" uuids)" || echo "Something went wrong with identifying that task's number."
[ ! -e "$location"/"$tu" ] && task "$1" minimal | tail -3 | head -1 > "$location"/"$tu" && echo '' >> "$location"/"$tu"
echo "$1" >> "$location"/"$tu"

nvim "$location"/"$tu"
