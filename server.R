library(shiny)
shinyServer(
	function(input, output) {
	    # This function checks whether the expiry date is less than or equal to the
	    # analysis date, and then sets it to the "analysis date + 1" if 
	    # true, or else leaves the expiry date as is, if false.
		tValues <- function(TT1, TT2) {
			if(TT2 <= TT1){
				TT2 <- TT1 + 1
				TT2 
			} else {
				TT2
			}
		}
        # This "stockData" function checks the system for the current date, 
        # calculates the value for date yesterday, and assigns this value it to 
        # a  variable "cutS" and then extracts substrings of the year, month, 
        # and day, and assigns those to variables "cutY", "cutM", and "cutD". 
        #
        # The function then uses the cutY, cutM, cutD variables as well as the 
        # choice of company in the input (input$company), to create a url and 
        # assigns this to a variable named "fileURL".
        #
        # This url is then used to extract stock price time-series data for the 
        # company of choice from the start of 2009 until yesterday from 
        # Yahoo.com, and assign it to a data frame named "priceData".
        #
        # The Date column in the priceData dataframe is then asssigned as a Date
        # variable, and finally this function outputs the resultant priceData 
        # data frame.
		stockData <- reactive({
			cutS <- as.character(Sys.Date() - 1)
			cutY <- substr(cutS, 1, 4)
			cutM <- substr(cutS, 6, 2)
			cutD <- substr(cutS, 9, 2)
            	fileURL <- paste("http://real-chart.finance.yahoo.com/table.csv?s=", 
                                 input$company, "&a=00&b=1&c=2009&d=", cutM, "&e=", 
                                 cutD, "&f=", cutY, "&g=d&ignore=.csv", sep = "")
			priceData <- read.table(fileURL, header = TRUE, sep = ",")
			priceData$Date <- as.Date(priceData$Date)
			priceData
		})
        # This function calculates the price of the opton given the analysis date,
        # option expiry date, option strike price, risk free interest rate, and 
        # option type.
        #
        # It loads the stockData function, then calculates the number of years 
        # between 
		pricerFn <- function(TT1, TT2, KK, RR, OT) {
            # Load the stockData function
			stockData()
            # Calculate the number of years between the option expiry date and
            # the pricing analysis date, by calling the tValues function.
			yDiff <- as.numeric(as.Date(tValues(TT1, TT2)) - as.Date(TT1)) / 365
            # Obtain the spot closing price of the stock on the pricing analysis date 
            # from the stockData function, and assign to variable "S".
			S <- as.numeric(stockData()[stockData()$Date == as.Date(TT1), ]$Close)
            # Obtain the closing prices of the stock for the year prior to the 
            # pricing analysis date from the stockData function, and assign to 
            # variable "previousPrices".
			previousPrices <- stockData()[stockData()$Date <= as.Date(TT1) & 
                                              stockData()$Date > 
                                              (as.Date(TT1) - 365), ]$Close
            # Calculate the series of returns from the previousPrices data, and 
            # assign to the variable "returns".
			returns <- (-1 * diff(previousPrices))/tail(previousPrices, -1)
            # Calculate the standard deviation of the returns variable, and 
            # assign to the variable "sigma".
			sigma <- sd(returns)
            # Convert the option strike price from the input to a numeric variable.
			K <- as.numeric(KK)
            # Convert the risk free interest rate from the input to a numeric 
            # variable, and divide this percentage by 100 to obtain a decimal 
            # figure. For example, 5% = 5 / 100 = 0.05
			rf <- as.numeric(RR) / 100
            # Create variables d1 and d2 as functions of the spot price, option 
            # strike price, the risk free interest rate, standard deviation of 
            # returns, and number of years between pricing analysis and option 
            # expiry dates.
			d1 <- (log(S / K) + ((rf + (0.5 * (sigma ^ 2))) * yDiff)) / 
                (sigma * (yDiff ^ 0.5))
			d2 <- d1 - (sigma * (yDiff ^ 0.5))
            # Calculate the price of a Put or Call option as a function of variables
            # d1, d2, the spot price, the option strike price, the risk free 
            # interest rate, and the number of years between pricing analysis and 
            # option expiry dates. Assign these values to variables "priceP" and 
            # "priceC" respectively.
			priceP <- (pnorm(-d2)* K * exp(-rf * yDiff)) - (pnorm(-d1) * S)
			priceC <- (pnorm(d1) * S) - (pnorm(d2) * K * exp(-rf * yDiff))
            # If the optionType from the input equals "Put" then output the priceP 
            # varaiable, otherwise output the priceC variable.
			if(OT == "Put") {
				priceP
			} else {
				priceC
			}
		}
        # This function plots the stock price time-series data obtained with the 
        # stockData() function.
		myPlot <- function(IC) {
			plot(stockData()$Date, stockData()$Close, type = "l", col = "limegreen", 
                 main = paste(IC, "stock prices", sep = " "), xlab = "Year", ylab = 
                     "Stock price (US$)")
		}
        # These commands output to the mainPanel, the choices made in the input
        # subPanel.
		output$company <- renderText({input$company})
		output$t <- renderText({as.character(input$t)})
		output$k <- renderText({input$k})
		output$r <- renderText({input$r})
		output$optionType <- renderText({input$optionType})
		output$T <- renderText({as.character(tValues(input$t, input$T))})
		output$optionPrice <- renderText({
			input$goButton
			isolate(pricerFn(input$t, input$T, input$k, input$r, input$optionType))
		})
		output$timePlot <- renderPlot({
			myPlot(input$company)
		})
	}
)