remove_acentos <- function(str,pattern="all") {
   if(!is.character(str))
    str <- as.character(str)
  
  pattern <- unique(pattern)
  
  if(any(pattern=="Ç"))
    pattern[pattern=="Ç"] <- "ç"
  
  acentuados <- c(
    agudo = "áéíóúÁÉÍÓÚýÝ",
    crase = "àèìòùÀÈÌÒÙ",
    circunflexo = "âêîôûÂÊÎÔÛ",
    til = "ãõÃÕñÑ",
    trema = "äëïöüÄËÏÖÜÿ",
    cedilha = "çÇ"
  )
  
  nao_acentuados <- c(
    agudo = "aeiouAEIOUyY",
    crase = "aeiouAEIOU",
    circunflexo = "aeiouAEIOU",
    til = "aoAOnN",
    trema = "aeiouAEIOUy",
    cedilha = "cC"
  )
  
  tipos <- c("´","`","^","~","¨","ç")
  
  if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern)) 
    return(chartr(paste(acentuados, collapse=""), paste(nao_acentuados, collapse=""), str))
  
  for(i in which(tipos%in%pattern))
    str <- chartr(acentuados[i],nao_acentuados[i], str)
  
  return(str)
}
