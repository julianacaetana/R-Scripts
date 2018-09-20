
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

setwd("D:/Pós Graduação/Projeto Aplicado/Scraping/Blogs e Sites/Valor")

valor <- read_csv("D:/Pós Graduação/Projeto Aplicado/Scraping/Blogs e Sites/Valor/valor_noticias_top10_paginas.csv", 
                 col_types = cols(X1 = col_skip(), data = col_character()), 
                 locale = locale(encoding = "WINDOWS-1252"))

for (i in 1:nrow(valor)) {
  
  text <- c(valor$titulo[i],valor$desc[i],valor$categoria_principal[i])
  text <- remove_acentos(text)
  docs <- Corpus(VectorSource(text))
  
  # toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
  # docs <- tm_map(docs, toSpace, "/")
  # docs <- tm_map(docs, toSpace, "@")
  # docs <- tm_map(docs, toSpace, "\\|")
  
  
  docs <- tm_map(docs, content_transformer(tolower))
  docs <- tm_map(docs, removeNumbers)
  docs <- tm_map(docs, removeWords, stopwords("pt-br"))
  docs <- tm_map(docs, removeWords, c("… leia","nao","alem")) 
  docs <- tm_map(docs, removePunctuation)
  docs <- tm_map(docs, stripWhitespace)
  docs <- tm_map(docs, stemDocument)
  
  
  dtm <- TermDocumentMatrix(docs)
  m <- as.matrix(dtm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  
  max <- max(d$freq)
  
  keywords <-  toString(filter(d,d$freq == max)$word  )
  
  valor$categoria_principal[i] <- keywords
  
  inspect(docs)
  
}



write.csv(valor, "valor_noticias_top10_paginas.csv")



