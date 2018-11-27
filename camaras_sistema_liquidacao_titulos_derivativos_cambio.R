
##### Selic, BM&FBOVESPA câmbio, BM&FBOVESPA ativos, BM&FBOVESPA derivativos, BM&FBOVESPA ações, CETIP, CIP C3 #####

options(timeout = 999999999)

for (i in 1:nrow(lista.outros.links)) {
  if(lista.outros.links$dataset[i] == "camaras-sistemas-de-liquidacao-de-titulos-derivativos-e-cambio"){
 
     
      
      download.file(lista.outros.links$url[i],
                    paste(str_trim(lista.outros.links$nome[i]), ".json",sep = ""))
    
    lista.outros.links$status[i] <- "OK"
      
    
  }
}