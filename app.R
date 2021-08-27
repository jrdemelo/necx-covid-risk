library(shiny)
library(xlsx)
library(ggplot2)

# formats the data for the download url and skips weekends
Year <-format(Sys.Date(), format="%Y")
Month <- tolower(format(Sys.Date(), format="%B"))
Day <- format(Sys.Date(), format="%d")
    if (format(Sys.Date(), format="%A") == "Monday"){
        Day <- as.numeric(Day)-3
        } else if (format(Sys.Date(), format="%A") == "Sunday"){
            Day <- as.numeric(Day)-2
            } else {
            Day <- as.numeric(Day)-1
            }
# downloads and parses data to get last 14 days of cases
madash <- paste0("https://www.mass.gov/doc/covid-19-raw-data-",Month,"-",Day,"-",Year,"/download")#download.file(madash, destfile = "./madata.xlsx", method="auto", mode="wb")
madata <- read.xlsx2("./madata.xlsx",5,header=TRUE)
madata <- subset(madata, select = -c(Positive.Total,Probable.Total,Probable.New,Estimated.active.cases))
madata$Date  <- as.integer(madata$Date)
madata$Positive.New  <- as.numeric(as.character(madata$Positive.New))
madata <- madata[order(-madata$Date),]
rownames(madata) <- NULL
madata <- head(madata, 14)
last14c <- sum(madata$Positive.New)

# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("The (Un)Official NECX Risk Calculator"),

    # Sidebar with variables to change based on race and relevant metrics 
    sidebarLayout(
        sidebarPanel(width = 4,
            #textInput("last14",
            #          "Cases in the past 14 days?",
            #          value = last14c),
            
            sliderInput("undercount",
                        "Undercount Factor:",
                        min = 1,
                        max = 5,
                        value = 1.7,
                        step = 0.1),
            sliderInput("qbreak",
                        "Percent of COVID+ population breaking quarantine:",
                        min = 0,
                        max = 100,
                        value = 20,
                        step = 1,
                        post = "%"),
            sliderInput("txrate",
                        "Outdoor transmission rate:",
                        min = 0.0,
                        max = 10,
                        value = 1,
                        step = 0.2,
                        post = "%"),
            sliderInput("fieldsize",
                        "Size of race field:",
                        min = 0,
                        max = 120,
                        value = 75),
            sliderInput("fieldexposure",
                        "Amount of field you're exposed to:",
                        min = 0,
                        max = 100,
                        value = 25,
                        post = "%")
            ),

        # Show cases counts and graph
        mainPanel(width = 8,
           textOutput("displaylast14c"),
           textOutput("displaycases"),
           textOutput("displayspreaders"),
           textOutput("displayodds"),
           plotOutput("oddsplot")
        )
    )
)

# Server functions that do the calculations for the odds
server <- function(input, output, session) {
    
    #universal variables
    mapop <- as.numeric(6893000)
    last14c <- as.numeric(last14c)
    
    #odds dataframe for graph
    oddsdf <- data.frame("base" = c(0,0,0,0,0,0,0,0,0),"odds" = c(160,250,750,1024,2000,2704,3000,3370,4464),"thing" = c("Audited by IRS","Having twins","Born with >10 fingers/toes","Heads/Tails 10x in a row","Astronaut application accepted","Same card from deck 2x","House burning down","Perfect score on SAT","Lost appendage to chainsaw"),"updown" = c(0.1,0.3,0.4,0.2,0.1,0.3,0.4,0.2,0.1),stringsAsFactors=FALSE)
    
    #runs through the odds and adjusts for undetected cases based on race size and exposure
    odds <- reactive({
        q <- input$qbreak/100
        l <- as.numeric(last14c)/mapop
        u <- input$undercount
        t <- input$txrate/100
        f <- input$fieldsize
        e <- input$fieldexposure/100
        fex <- f*e
        mapos <- ((l*u)-l)+(l*q)
        posnotx <- 1-(mapos*t)
        yestx <- 1-(posnotx^fex)
        txodds <- prettyNum(ceiling(1/yestx), big.mark = ",", scientific = FALSE)
        
    })
    
    #calculates true cases
    cases <- reactive({
        q <- input$qbreak/100
        l <- as.numeric(last14c)
        u <- input$undercount
        cases <- prettyNum(ceiling((l*u)),big.mark = ",", scientific=FALSE)
        
    })
    
    #calculates how many people are out in the state vs quarantined
    spreaders <- reactive({
        q <- input$qbreak/100
        l <- as.numeric(last14c)
        u <- input$undercount
        spreaders <- prettyNum(ceiling(((l*u)-l)+(l*q)),big.mark = ",",scientific=FALSE)
        
    })
    
    #creates the dataframe for your odds
    youroddsdf <- reactive({
        q <- input$qbreak/100
        l <- as.numeric(last14c)/mapop
        u <- input$undercount
        t <- input$txrate/100
        f <- input$fieldsize
        e <- input$fieldexposure/100
        fex <- f*e
        mapos <- ((l*u)-l)+(l*q)
        posnotx <- 1-(mapos*t)
        yestx <- 1-(posnotx^fex)
        txodds <- ceiling(1/yestx)
        youroddsdf <- data.frame("base" = c(0),"odds" = c(txodds),"thing" = c("YOUR ODDS"),"updown" = c(0.55),stringsAsFactors=FALSE)
        
    })

    
    #outputs for ui
    output$displaylast14c <- renderText({
        paste0("Number of documented cases in MA in the past 14 days: ", prettyNum(last14c,big.mark = ",", scientific=FALSE))
    })
    output$displaycases <- renderText({
        paste0("Number of total cases in MA incl. undetected: ", cases())
    })
    output$displayspreaders <- renderText({
        paste0("Number of spreaders in MA (asymptomatic + quarantine breakers): ", spreaders())
    })
    output$displayodds <- renderText({
        paste0("Your odds are catching COVID at this race are approximately: 1 in ", odds())
        })
    
    output$oddsplot <- renderPlot({
        ggplot(oddsdf, aes(x=odds,y=base))+
            
            geom_segment(aes(x=odds,y=updown,xend=odds),data=youroddsdf(),yend=0,color="red")+
            geom_segment(aes(x = 0,y = base,xend = 5000,yend=0),data=youroddsdf())+
            geom_point(color="red",size=4,shape=16,data=youroddsdf())+
            geom_label(aes(x=odds,y=updown,label=thing),data=youroddsdf(),color="red",fontface="bold",size=6)+
            
            geom_segment(aes(x=odds,y=updown,xend=odds),data=oddsdf,yend=0)+
            geom_segment(aes(x = 0,y = base,xend = 5000,yend=0),data=oddsdf)+
            geom_point(color="black",size=3,shape=16,data=oddsdf)+
            geom_label(aes(x=odds,y=updown,label=thing),data=oddsdf,fill="white",size=5)+            
            
            
            scale_x_continuous(name="1 in every x times", breaks = seq(0,5000,500), limits = c(-300,5300))+  
            ylim(0,1)+
            theme(panel.background = element_rect(fill="white"),
                  axis.title.y = element_blank(),
                  axis.text.y = element_blank(),
                  axis.ticks.y = element_blank(),
                  axis.text.x = element_text(size = 12)
            )
    })
    }

# Run the application 
shinyApp(ui = ui, server = server)
