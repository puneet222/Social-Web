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

## below this line all the text mining is done in windows because tm package is not installing in ubuntu

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


# above this line all is done in windows




 ref <- read.csv("holala.csv")  #read the table
  str(ref)

  mydb = dbConnect(MySQL(), user='root', password='Incorrect', dbname='data_mining', host='localhost')
#reconnection with MySQL

dbWriteTable(mydb, name='proto_table', value=ref) #making a table having the value of new refined data

#now apply some queries....

query1 <- "SELECT count(*) from proto_table where msg like '%c++%'" ;

time2 <- raw$querytime #we also need store the time for future needs

#time2 has many same times so we need just one

time <- time2[2] ;

res <- dbSendQuery(mydb , query1) ;

count_of <- fetch(res , n=-1);

count_of <- count_of[1,1] #because it is a dataframe

#make a data frame of count and date and store it in a table in database

total_cpp <- data.frame(date = time , cpp_count = count_of)

dbWriteTable(mydb , name="proto_total_cpp" , value=total_cpp) ;
