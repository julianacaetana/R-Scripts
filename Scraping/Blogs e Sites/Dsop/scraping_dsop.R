library(rvest)
library(XML)
library(dplyr)
library(stringr)

con <- url('http://www.dsop.com.br/category/para-voce/noticias/')
url_base <- "www.dsop.com.br"
page_base <- read_html(con)

paginas <- as.integer(html_text(html_nodes(page_base,xpath ='//*[@id="content"]/header/nav/ul/li[6]/a' ),trim = T))


dsop.noticias <- data.frame()

for (x in 1:10) {
  if (x == 1 ){
    url<- url('http://www.dsop.com.br/category/para-voce/noticias/') 
    
  }
  else{
    url<- url(paste('http://www.dsop.com.br/category/para-voce/noticias/page/',x,'/',sep = "") )
  }
  
  page <- read_html(url)
  qtd <- length(html_nodes(page,xpath ='//*[@id="content"]/header/article' ))
  
  for (i in 1:qtd) {
    
    
    t <- html_nodes(page,xpath ='//*[@id="content"]/header/article')[i][[1]]

    
    temp <- data.frame(titulo = html_text( html_node(t,"header h1"), trim = T),
                       link = html_attr( html_node(t,"header a"),"href"),
                       desc = html_text( html_node(t,"p"), trim = T),
                       data = html_attr( html_node(t,"header .entry-date"), "datetime"),
                       categoria_principal = str_trim(str_split( html_text( html_node(t,'div'), trim = T) ,"[|]")[[1]][2])
                       )
    
    dsop.noticias <- bind_rows(dsop.noticias,temp)
    
  }

}


dsop.noticias <- filter(dsop.noticias,dsop.noticias$categoria_principal == "Notícias para você")

##setwd("D:/Pós Graduação/Projeto Aplicado/Scraping/Blogs e Sites/Dsop")
write.csv(dsop.noticias, "dsop_noticias_top10_paginas.csv")

