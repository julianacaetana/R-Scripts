library(rvest)
library(XML)
library(dplyr)
library(stringr)

con <- url('https://www.valor.com.br/ultimas-noticias/financas')
url_base <- "www.valor.com.br"
page_base <- read_html(con)

paginas <-str_split( html_attr(html_nodes(page_base,xpath ='//*[@id="block-valor_capa_automatica-central_automatico"]/div[3]/ul/li/a' ),'href')[10],"=")[[1]][2]


valor.noticias <- data.frame()

for (x in 1:10) {
  if (x == 1 ){
    url<- url('https://www.valor.com.br/ultimas-noticias/financas') 
    
    }
  else{
    url<- url(paste('https://www.valor.com.br/ultimas-noticias/financas?page=',x,sep = "") )
  }

  page <- read_html(url)
  qtd <- length(html_nodes(page,xpath ='//*[@id="block-valor_capa_automatica-central_automatico"]/div[2]/div' ))

for (i in 1:qtd) {


t <- html_nodes(page,xpath =paste('//*[@id="block-valor_capa_automatica-central_automatico"]/div[2]/div[',i,']',sep="") )

temp <- data.frame(titulo = html_text( html_node(t[[1]],"h2"), trim = T),
           link = paste( url_base, html_attr( html_node(t[[1]],"h2 a"),"href"),sep = ""),
           desc = html_text( html_node(t[[1]],"p"), trim = T),
           data = html_text( html_node(t[[1]],"div .date"), trim = T),
           categoria_principal = html_text( html_node(t[[1]],"div .section-title"), trim = T) )

valor.noticias <- bind_rows(valor.noticias,temp)

}

}


