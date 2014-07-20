#install.packages("quantmod")
library("quantmod")
#Script to download prices from yahoo
#The tickers will be loaded from a csv file
#prices are saved to stockData environment
#weekly returns are saved to stockReturns environment

#Script Parameters
tickerlistfile <- "/Users/jwalsh/Documents/Home/trading/etfTickerlists20140712/iyc.txt" #CSV containing tickers on rows
savefilename <- "stockdata.RData" #The file to save the data in
startDate = as.Date("2009-07-10") #Specify what date to get the prices from
maxretryattempts <- 5 #If there is an error downloading a price how many times to retry

#Load the list of ticker symbols from a csv, each row contains a ticker
stockstable <- read.table(tickerlistfile,stringsAsFactors = F, strip.white=TRUE)
stockslist<-stockstable[,1]
stockData <- new.env() #Make a new environment for quantmod to store data in
stocksnumber = length(stockslist) #The number of stocks to download

#Download all the stock data
for (i in 1:stocksnumber){
tryCatch( {  
  getSymbols(stockslist[i], env = stockData, src = "yahoo", from = startDate)
}, error=function(cond) {message(paste("problem downloading:", stockslist[i]))
message(cond)
}, warning=function(cond) {message(paste(stockslist[i], "caused a download warning"))
})
}

#create weekly returns for dowloaded data
stockReturns<-new.env()
for (i in 1:stocksnumber) {
  tryCatch( {assign(paste(stockslist[i],sep="",".W"),weeklyReturn(eval(parse(text=paste("stockData$",stockslist[i],sep="")))),pos=stockReturns)},
            error=function(cond) {message(paste("problem generating WR:", stockslist[i]))
                                  message(cond)
            }, warning=function(cond) {message(paste(stockslist[i], "caused an error generating return"))
            })}

#print debug data for downloads and returns
cat("stockslist has:", length(stockslist))
cat("stockData has:", length(ls(stockData)))
cat("stockReturns has:", length(ls(stockReturns)))
