
# install.packages("tm")  
# install.packages("SnowballC") 
# install.packages("wordcloud")  
# install.packages("RColorBrewer") 


library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library("stringr")
library("dplyr")

setwd("D:/Pós Graduação/Projeto Aplicado/Scraping/Dados Abertos BC/IndiceDatasets")

lista.dataset <-

  read.table("D:/Pós Graduação/Projeto Aplicado/Scraping/Dados Abertos BC/IndiceDatasets/lista_dataset.txt",
             header = T,sep = "|",quote = "\"")




for (i in 1:nrow(lista.dataset)) {

  text <- c(toString(lista.dataset$notas[i]),toString(lista.dataset$dataset[i]))
  text <- remove_acentos(text)
  docs <- Corpus(VectorSource(text))
  
  # toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
  # docs <- tm_map(docs, toSpace, "/")
  # docs <- tm_map(docs, toSpace, "@")
  # docs <- tm_map(docs, toSpace, "\\|")
  inspect(docs)
  
  docs <- tm_map(docs, content_transformer(tolower))
  docs <- tm_map(docs, removeNumbers)
  docs <- tm_map(docs, removeWords, stopwords("pt-br"))
  docs <- tm_map(docs, removeWords, c("… leia","nao","alem","banco","central","dia")) 
  docs <- tm_map(docs, removePunctuation)
  docs <- tm_map(docs, stripWhitespace)
  docs <- tm_map(docs, stemDocument)
  
  
  dtm <- TermDocumentMatrix(docs)
  m <- as.matrix(dtm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  

  
  keywords <-  toString( top_n(d,5,d$freq)$word )
  
  lista.dataset$categoria_principal[i] <- keywords
  
  inspect(docs)
  
}



write.csv(lista.dataset, "lista_dataset_classificada.csv",row.names = F)



