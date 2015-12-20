#!/bin/bash
#De base on affiche rien
affichage=false
#On va lire l'option si il y en a une
while getopts "v" option
do
	case $option in
		#Si on a l'option v
		v)affichage=true
		shift;;
		#Si a autre chose que l'option v
		?)echo "usage: option inconnue"
		exit 1;;
	esac
done
#Je stocke les nom des fichiers 1 et 2 dans des variable f1 et f2
f1=$1
f2=$2

#Version naive
naive(){
	echo "Version naive"
cat $f1 | while read line
do
	if grep -qx $line $f2 
	then
		if $affichage && [ -n "$line" ]
		then
			echo $line >> /tmp/commun.$$
			#echo "ligne= $line"
			#echo `grep $line $f2`
		fi
	fi
	done 
if cat /tmp/commun.$$ >/dev/null 2>/dev/null
then
	echo "Les lignes en commun sont:"
	cat /tmp/commun.$$
	rm -f /tmp/commun.$$
fi
}

#Version optimisée
opti(){
	echo Opti
	#Je trie le fichier d'entrée et créer un fichier temp
	cat $f1 | sort | uniq >/tmp/f1.$$
	#Je lis le fichier /tmp/f1.$$ ligne par ligne
	while read line
	do
		#Si on grep la ligne
		if grep -qx $line $f2 
		then
			#Si j'ai l'option v
			if $affichage 
			then
				#On redirige la ligne grep vers un fichier temp
				echo $line >> /tmp/commun.$$
			fi
		fi
	done < /tmp/f1.$$
	#Si on a eu des lignes en commun entre les deux fichiers
	if cat /tmp/commun.$$ >/dev/null 2>/dev/null
	then
		echo "Les lignes en commun sont:"
		cat /tmp/commun.$$
		#Je supprime le fichier temp que j'ai affiché juste avant
		rm -f /tmp/commun.$$
	fi
	#Je supprime le fichier dont j'ai lu les lignes
	rm -f /tmp/f1.$$ 
}

echo "Temps naive:"
# On recupere le temps réel d'excution de la version naive
time_naive=`(time -p naive) 2>&1 | grep real | sed "s/real //g"`
echo $time_naive

# On recupere le temps réel d'excution de la version optimiséé
time_opti=`(time -p opti) 2>&1 | grep real | sed "s/real //g"`
echo "Temps opti:"
echo $time_opti 

# On calcule la taile du fichier 2 en ko
size_f2=`ls -s $f2 | cut -d' ' -f1`

# ON crée le fichier d'entrée pour faire le graphe
echo $size_f2 $time_naive $time_opti >> graph_programme

#On va trier la liste par taille de fichiers
cat graph_programme | sort -k1n,1n > /tmp/graphique.$$
cat /tmp/graphique.$$ > graph_programme
./graphe.sh graph_programme

echo "Valeurs dans le graph. :"
cat graph_programme

echo "Voulez vous effacer le fichier [y-n]"
read choix
if [ $choix = "y" ]
then
	# Si oui on efface le programme
	rm -f graph_programme
fi
	
#On eface les fichiers temps
rm -f /tmp/graphique.$$
