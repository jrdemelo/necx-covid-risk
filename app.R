library(shiny)
library(xlsx)

# retreives ma covid data and gets case numbers for the last 14 days
Year <-format(Sys.Date(), format="%Y")
Month <- tolower(format(Sys.Date(), format="%B"))
Day <- format(Sys.Date(), format="%d")
madash <- paste0("https://www.mass.gov/doc/covid-19-raw-data-",Month,"-",Day,"-",Year,"/download")
madata <- read.xlsx2("./madata.xlsx",5,header=TRUE)
madata <- subset(madata, select = -c(Positive.Total,Probable.Total,Probable.New,Estimated.active.cases))
madata$Date  <- as.integer(madata$Date)
madata$Positive.New  <- as.numeric(as.character(madata$Positive.New))
madata <- madata[order(-madata$Date),]
rownames(madata) <- NULL
madata <- head(madata, 14)
last14c <- sum(madata$Positive.New)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("The (Un)Official NECX Risk Calculator"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(width = 5,
            textInput("last14",
                      "Cases in the past 14 days?",
                      value = last14c),
            
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
                        value = 50,
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

        # Show a plot of the generated distribution
        mainPanel(width = 7,
           textOutput("displaylast14c"),
           textOutput("displaycases"),
           textOutput("displayspreaders"),
           textOutput("displayodds")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    mapop <- as.numeric(6893000)
    last14c <- as.numeric(last14c)
    
    odds <- reactive({
        q <- input$qbreak/100
        l <- as.numeric(input$last14)/mapop
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
    
    cases <- reactive({
        q <- input$qbreak/100
        l <- as.numeric(input$last14)
        u <- input$undercount
        cases <- prettyNum(ceiling((l*u)),big.mark = ",", scientific=FALSE)
        
    })
    
    spreaders <- reactive({
        q <- input$qbreak/100
        l <- as.numeric(input$last14)
        u <- input$undercount
        spreaders <- prettyNum(ceiling(((l*u)-l)+(l*q)),big.mark = ",",scientific=FALSE)
        
    })
    
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

    }

# Run the application 
shinyApp(ui = ui, server = server)
