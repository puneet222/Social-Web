raw <- read.csv("ok2.csv" , header=T , sep=";") ;
#ok2.csv is temporary   file for testing data analysis
# in raw object we have the contents of the csv file
str(raw) ; #str for structure i.e. what are the variables etc ;

id <- raw$id ; #from raw we need only id and messages ;(kind of only messages)
msg <- raw$message ;
df <- data.frame(id = id , msg = msg)
msg
#connection of R with MySQL for putting the contents in the database and quering the data
library(RMySQL) #package used to connect MySQL with R
mydb = dbConnect(MySQL(), user='root', password='Incorrect', dbname='data_mining', host='localhost')

library(tm)
mycorpus <- Corpus(VectorSource(msg))
#making a corpus (used to store the documents/text) ;
inspect(mycorpus[1])
mycorpus <- tm_map(mycorpus, tolower)
#mycorpus <- tm_map(mycorpus , removePunctuation) don,t use this because i need punctuation

mycorpus <- tm_map(mycorpus , removeWords , stopwords("english")) #obvious
library(SnowballC)
mycorpus <- tm_map(mycorpus , stemDocument)  # removes 'ing' , 'es' etc from the text
mycorpus <- tm_map(mycorpus , stripWhitespace)  #obvious
#mycorpus <- tm_map(mycorpus , PlainTextDocument)

ls()
var <- mycorpus$content #to get the content from the corpus metadata 

removeURL <- function(x) gsub("http[[:alnum:][:punct:]]*", "", x) #to remove the links in the messages
var <- removeURL(var)
var
var[2]
newdata2 <- data.frame(id = id , msg = var)  #making a data frame with refined data

write.csv(newdata2 , file="holala.csv") #write that data to a csv file
