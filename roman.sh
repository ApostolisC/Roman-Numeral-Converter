#!/bin/bash
#Here we will create some lists. Each item from alph is linked to the corresponding item from num list. alph[0]==num[0] and so on..
#items list is the combination of the 2 lists:alph,num. Sometimes we need to use the items list but other times just the alph.
alph=(I V X L C D M)
num=(1 5 10 50 100 500 1000)
items=(1	I 4	IV 5 V 9	IX 10	X 40	XL 50	L 90	XC 100	C 400	CD 500	D 900	CM 1000 M)

read -p "Input: " input #read input from user. It can be either number or letters

has_numbers=0 #Here 0 means no and 1 means yes
has_letters=0

# CHECK IF INPUT IS STRING OR LETTERS
if ! [[ "$input" =~ ^[0-9]+$ ]]
    then has_letters=1 # mark that we have not numbers
else has_numbers=1 #mark that input is numbers only
fi


# IF IT IS LETTERS CHECK IF IT HAS NUMBERS IN IT
if [[ $has_letters -eq 1 ]] && [[ $input =~ [0-9] ]]; then
  echo "[!] Invalid Input. Please try again" # in that case a string wich is letters cannot have numbers
  exit
fi


# USER MUST ENTER NUNMBER LOWER THAN 4000 OR <=3999
if [[ $has_numbers -eq 1 && ( ! ( $input -lt 4000 && $input -gt 0 ) ) ]]; then
  echo "[!] Please enter number from range 1-3999" $has_numbers $has_letters
  exit
fi


# BREAK THE INPUT INTO SINGLE CHARACTERS
input_list=() # here will be stored the characters from input string
for ((i=0;i<${#input};i++)); do
    input_list+=(${input:i:1}) #Here we are breaking the input into single charactes so we have iterate between them
done


# IF INPUT IS LETTERS THEN WE NEED TO CHECK FOR ILLEGAL CHARACTERS OTHER THAN THOSE IN alph LIST
if [[ $has_letters -eq 1 ]]; then
  for value in "${input_list[@]}" #for each character in input_list SEE LINE 32-35
  do
    if [[ $value2 == "V" || $value2 == "L" || $value2 == "D" ]]; then #Here we check if V,L,D are repeated. They should not!
      result=${input//[^$value2]}
      if [[ ${#result} -gt 1 ]]; then
        echo "Wrong input. [Note]: Characters V,L and D cannot be repeated!"
        exit
      fi
    fi
    found=0 #character input not in valid letters
    for value2 in "${alph[@]}" # for each character in alph list
      #HERE FOR EVERY CHARACTER OF USER INPUT WE MUST CHECK IF ALL OF THESE CHARACTERS ARE IN alph LIST (SEE LINE 3).
      #But we must also perform aditional checks to validate the input. One of these check is that V,L,D characters cannot be repeated
      do
        if [[ $value == $value2 ]]; then
          found=1 #character input in valid letters
          break
        fi
      done
      if [[ $found -eq 0 ]]; then # It means the last character we checked from users input is not in alph list (see line 3), which contains the valid roman letters
        echo "[!] Invalid Input. Please try again"
        exit
      fi
  done
fi


index=() #extract places .Here we will extract the place of each character in items list (see line 5). So the value of each character is in the previous place of items list
for value in "${input_list[@]}"; do
    for ((i=1;i<26;i+=2)); do
      if [[ $value == ${items[$i]} ]]; then
        index+=($i)
        #let result+=${num[i]}
      fi
    done
done


# IF INPUT IS LETTERS THEN WE NEED TO MAKE SURE THERE IS NOT A CHARACTER MORE THAN 3 TIMES
# We also check if V,L,D are not on the left side of a bigger value,
# And if I is on the left side of X,V. I can be subtracted only with X AND V
app=(0 0 0 0 0 0 0)
if [[ $has_letters -eq 1 ]]; then
  for ((i=0;i<${#index[@]};i++)) do
    if [[ ( ${items[${index[$i]}]} == "L" || ${items[${index[$i]}]} == "D" || ${items[${index[$i]}]} == "V" ) && ( ${index[$i]} -lt ${index[$i+1]} ) ]]; then #V,L,D cannot be before a bigger value
      echo Wrong input. [Note]: Charactes V,L,D cannot be on the left side of a bigger value
      exit
    elif [[ ( ${index[$i]} -lt ${index[$i+1]} ) && ( ${items[${index[$i]}]} == "I" && ! ( ${items[${index[$i+1]}]} == "V" || ${items[${index[$i+1]}]} == "X" ) ) ]]; then
      #Here we check if I is subtracted with others than V and X
      echo Wrong input. [Note]: Character I can be subtracted only with characters X and V
      exit
    elif [[ ${items[${index[$i]}]} == "X" && ( ${items[${index[$i+1]}]} == "D" || ${items[${index[$i+1]}]} == "M" ) ]]; then
      # Here we check if  X is just before D and M. X cannot be subtracted with D,M
      echo Wrong Input. [Note]: Character X cannot be subtracted with characters D and M
      exit
    fi
  done
  for (( i = 0; i < ${#index[@]}-3; i++ )); do
    if [[ ${index[$i]} -eq ${index[$i+1]} && ${index[$i]} -eq ${index[$i+2]} && ${index[$i]} -eq ${index[$i+3]} ]];then
      #Here we check if a number appears more than 3 times
      echo Wrong input. [Note]: Character cannot be repeated more than 3 times!
      exit
    fi
  done
fi


# here we make sure that if we need to subtract then this value * 10 is not less than the sum of the next 2. For example IXX . I*10=10 X+X=20 10<20. IXX is invalid!
for ((i=0;i<${#index[@]};i++)); do
  if ! [[ ${index[$i+2]} -lt ${index[$i+1]} ]]; then #if we find a number to be subtracted
    # if the next value and the next from the next value is more than 10 times the current value: its wrong input
    if [[ $((${items[${index[$i]}-1]} * 10)) -lt $((${items[${index[$i+1]}-1]} + ${items[${index[$i+2]}-1]})) ]]; then
      echo Wrong Input. [Note]: A number cannot be subtracted from a number 10 times greater
      echo In your case ${items[${index[$i]}-1]}*10=$((${items[${index[$i]}-1]} * 10)) is less than ${items[${index[$i+1]}-1]}+${items[${index[$i+2]}-1]}=$((${items[${index[$i+1]}-1]} + ${items[${index[$i+2]}-1]}))
      exit
    fi
  fi
done


#NOW WE HAVE EITHER NUMBER OR CHARACTERS. JUST 2 CASES
if [[ $has_letters -eq 1 ]]; then #case from roman to number
  #input_list[${#input_list[@]}]=${input_list[${#input_list[@]}-1]}
  index[${#index[@]}]=${index[${#index[@]}-1]} # we add the last character of index list to the end
                                              #so while we compare a value with the next we wont find nothing. So we will something that equals which is ok
  #For each item from index list (Which contains the places of each character in items list (see line 5))
  #we compare it with the next. If the place is smaller then the value is smaller so we need to subtract else to just add value to total
  for ((i=0;i<${#index[@]}-1;i++)); do
    if [[ ${index[$i]} -lt ${index[$i+1]} ]]; then #value is smaller than the next
      result=$(($result-${items[${index[$i]}-1]})) #we find the value to items list and remove the value from the total
    else
      result=$(($result+${items[${index[$i]}-1]})) # value is bigger than the next. so we just add the value
    fi
  done
  echo Result: $result ! #printing the result
else
  #Logic taken from here: https://www.rapidtables.com/convert/number/how-number-to-roman-numerals.html
  x=$input #copy the input
  while [[ $x -ne 0 ]]; do #while x is not 0
    #find max
    max=items[0] # let it be max
    index=0
    n=2
    while ! [[ ${items[$n]} -gt $x ]] && [[ ${items[$n]} -gt $max ]] && [[ $n -lt 26 ]]; do
      max=${items[$n]} #set new max
      index=$n #set new max index
      n=$(($n+2)) # items is number1 char1 number2 char2. Thats why we add 2. We do not need the next but 2 indexes to the right
    done
    result+=${items[$index+1]} # add to result
    x=$(($x-${items[$index]})) # remove what we added until x=0
  done
  echo Result: $result ! # printing the result
fi
