#install.packages("quantmod")
library("quantmod")
#Script to download prices from yahoo
#The tickers will be loaded from a csv file
#prices are saved to stockData environment
#weekly returns are saved to stockReturns environment

#Script Parameters
tickerlist <- "/Users/jwalsh/Documents/Home/trading/etfTickerlists20140712/etfList.txt" #CSV containing tickers on rows
savefilename <- "stockdata.RData" #The file to save the data in
startDate = as.Date("2009-07-10") #Specify what date to get the prices from
maxretryattempts <- 5 #If there is an error downloading a price how many times to retry

#Load the list of ticker symbols from a csv, each row contains a ticker
stocksLst <- read.table(tickerlist,stringsAsFactors = F, strip.white=TRUE)
stockData <- new.env() #Make a new environment for quantmod to store data in
nrstocks = length(stocksLst[,1]) #The number of stocks to download

#Download all the stock data
for (i in 1:nrstocks){
  for(t in 1:maxretryattempts){
    
    tryCatch(
{
  #This is the statement to Try
  #Check to see if the variables exists
  #NEAT TRICK ON HOW TO TURN A STRING INTO A VARIABLE
  #SEE  http://www.r-bloggers.com/converting-a-string-to-a-variable-name-on-the-fly-and-vice-versa-in-r/
  if(!is.null(eval(parse(text=paste("stockData$",stocksLst[i,1],sep=""))))){
    #The variable exists so dont need to download data for this stock
    #So lets break out of the retry loop and process the next stock
    #cat("No need to retry")
    break
  }
  
  #The stock wasnt previously downloaded so lets attempt to download it
  cat("(",i,"/",nrstocks,") ","Downloading ", stocksLst[i,1] , "\t\t Attempt: ", t , "/", maxretryattempts,"\n")
  getSymbols(stocksLst[i,1], env = stockData, src = "yahoo", from = startDate)
}
#Specify the catch function, and the finally function
, error = function(e) print(e))
  }
}

#create weekly returns for dowloaded data

for (i in 1:length(stocksLst[,1])) {
  assign(paste(stocksLst[i,1],sep="",".W"),weeklyReturn(eval(parse(text=paste("stockData$",stocksLst[i,1],sep="")))),pos=stockReturns)
}

#Lets save the stock data to a data file
#tryCatch(
#{
#  save(stockData, file=savefilename)
#  cat("Sucessfully saved the stock data to %s",savefilename)
#}
#, error = function(e) print(e))