#
# TODO: DRY ggsave calls into function.
# TODO: Add Intro to the functions and files.
#

wd <- getwd()
library('glue')
library('stringr')
library('svglite')

source("source/createPlot.R", local = TRUE)
source("source/formatCode.R", local = TRUE)
#source("source/downloadPlot.R", local = TRUE)
source("source/dataUpload.R", local = TRUE)
server <- function(input, output, session) {
  
  # Read the input data.
  inputData <- callModule(dataUpload, "rainCloud")
  
  # Process the data. This is a reactive depending on the inputData!
  processedData <- reactive({callModule(dataManipulation, "rainCloud", 
                              inputData,
                              input$filterColumns)})

  # UI - Data - Filter the data.
  output$DataFilterColumnsUI <- renderUI({
    req(inputData$conditions())
    selectInput('filterColumns',
                label = HTML("<h5>Detected columns</h5>
                             <p>Use this input to filter out or move columns.</p>"), 
                choices = inputData$conditions(),
                selected = inputData$conditions(),
                multiple = TRUE)
  })
  
  # UI - Stats - pairwise comparison input.
  output$statsCombinationsUI <- renderUI({
    combinationList <- combn(input$filterColumns, 2, FUN = paste, 
                             collapse = 'vs')
    selectInput("statsCombinations", 
                label = h5("Conditions To Test"),
                choices = combinationList,
                multiple = TRUE)
  })
  
  # UI - Stats - default multiple comparison label height.
  output$statsLabelUI <- renderUI({
    numericInput('statsLabelY',
                 label = h5("Multiple Significance Label Y height"), 
                 min = 0, 
                 value = round(max(processedData()$df()$value)*1.05))
  })
  
  # UI - Plot - default scale limits.
  output$scaleLimitsUI <- renderUI({
    tagList(
      column(6,
             numericInput("minScale", 
                          label = h5("Min Scale Limit"), 
                          value = 0)
      ),
      column(6,
             numericInput("maxScale", 
                          label = h5("Max Scale Limit"), 
                          value = round(max(processedData()$df()$value)*1.1))
      )
    )
  })
  
  # Templates: update the values:
  observeEvent(input$template_raincloud, {
    # General
    updateCheckboxInput(session, "plotFlip", value = FALSE)
    # Dots
    updateCheckboxInput(session, "plotDots", value = TRUE)
    updateSelectInput(session, "dotColumnType", selected = "jitterDots")
    updateSliderInput(session, "dotsWidth", value = 0.15)
    # Violins
    updateCheckboxInput(session, "plotViolins", value = TRUE)
    updateSelectInput(session, "violinType", selected = "geom_flat_violin")
    updateCheckboxInput(session, "violinTrim", value = TRUE)
    updateSliderInput(session, "violinNudge", value = 0.2)
    updateSliderInput(session, "violinAlpha", value = 0.6)
    # Boxplots
    updateCheckboxInput(session, "boxPlots", value = TRUE)
    updateCheckboxInput(session, "boxplotNotch", value = TRUE)
    updateSliderInput(session, "boxplotNudge", value = 0.2)
    updateSliderInput(session, "boxplotAlpha", value = 0.3)
    # Mean
    updateCheckboxInput(session, "statsMean", value = FALSE)
  })
  observeEvent(input$template_rainclouds_flipped, {
    # General
    updateCheckboxInput(session, "plotFlip", value = TRUE)
    # Dots
    updateCheckboxInput(session, "plotDots", value = TRUE)
    updateSelectInput(session, "dotColumnType", selected = "jitterDots")
    updateSliderInput(session, "dotsWidth", value = 0.15)
    # Violins
    updateCheckboxInput(session, "plotViolins", value = TRUE)
    updateSelectInput(session, "violinType", selected = "geom_flat_violin")
    updateCheckboxInput(session, "violinTrim", value = TRUE)
    updateSliderInput(session, "violinNudge", value = 0.2)
    updateSliderInput(session, "violinAlpha", value = 0.6)
    # Boxplots
    updateCheckboxInput(session, "boxPlots", value = TRUE)
    updateCheckboxInput(session, "boxplotNotch", value = TRUE)
    updateSliderInput(session, "boxplotNudge", value = 0.2)
    updateSliderInput(session, "boxplotAlpha", value = 0.3)
    # Mean
    updateCheckboxInput(session, "statsMean", value = FALSE)
  })
  observeEvent(input$template_data_boxplots, {
    # General
    updateCheckboxInput(session, "plotFlip", value = FALSE)
    # Dots
    updateCheckboxInput(session, "plotDots", value = TRUE)
    updateSelectInput(session, "dotColumnType", selected = "jitterDots")
    updateSliderInput(session, "dotsWidth", value = 0.15)
    # Violins
    updateCheckboxInput(session, "plotViolins", value = FALSE)
    # Boxplots
    updateCheckboxInput(session, "boxPlots", value = TRUE)
    updateCheckboxInput(session, "boxplotNotch", value = TRUE)
    updateSliderInput(session, "boxplotNudge", value = 0.3)
    updateSliderInput(session, "boxplotAlpha", value = 0.6)
    # Mean
    updateCheckboxInput(session, "statsMean", value = FALSE)
  })
  observeEvent(input$template_mean_se, {
    # General
    updateCheckboxInput(session, "plotFlip", value = FALSE)
    # Dots
    updateCheckboxInput(session, "plotDots", value = TRUE)
    updateSelectInput(session, "dotColumnType", selected = "beeswarm")
    updateSliderInput(session, "dotsWidth", value = 0.15)
    # Violins
    updateCheckboxInput(session, "plotViolins", value = FALSE)
    # Boxplots
    updateCheckboxInput(session, "boxPlots", value = FALSE)
    # Mean
    updateCheckboxInput(session, "statsMean", value = TRUE)
    updateSelectInput(session, "statsMeanErrorBars", selected = "mean_se")
    updateSliderInput(session, "statsMeanWidth", value = 0.5)
    updateSliderInput(session, "statsMeanNudge", value = 0)
    updateSliderInput(session, "statsMeanSize", value = 1)
  })
  observeEvent(input$template_data_violins, {
    # General
    updateCheckboxInput(session, "plotFlip", value = FALSE)
    # Dots
    updateCheckboxInput(session, "plotDots", value = TRUE)
    updateSelectInput(session, "dotColumnType", selected = "beeswarm")
    updateSliderInput(session, "dotsWidth", value = 0.15)
    # Violins
    updateCheckboxInput(session, "plotViolins", value = TRUE)
    updateSelectInput(session, "violinType", selected = "geom_violin")
    updateCheckboxInput(session, "violinTrim", value = TRUE)
    updateSliderInput(session, "violinNudge", value = 0)
    updateSliderInput(session, "violinAlpha", value = 0.3)
    updateCheckboxInput(session, "violinQuantiles", value = TRUE)
    # Boxplots
    updateCheckboxInput(session, "boxPlots", value = FALSE)
    # Mean
    updateCheckboxInput(session, "statsMean", value = FALSE)
  })
  observeEvent(input$template_boxplots_violins, {
    # General
    updateCheckboxInput(session, "plotFlip", value = FALSE)
    # Dots
    updateCheckboxInput(session, "plotDots", value = FALSE)
    # Violins
    updateCheckboxInput(session, "plotViolins", value = TRUE)
    updateSelectInput(session, "violinType", selected = "geom_violin")
    updateCheckboxInput(session, "violinTrim", value = TRUE)
    updateSliderInput(session, "violinNudge", value = 0)
    updateSliderInput(session, "violinAlpha", value = 0.2)
    updateCheckboxInput(session, "violinQuantiles", value = FALSE)
    # Boxplots
    updateCheckboxInput(session, "boxPlots", value = TRUE)
    updateCheckboxInput(session, "boxplotNotch", value = TRUE)
    updateSliderInput(session, "boxplotNudge", value = 0)
    updateSliderInput(session, "boxplotAlpha", value = 0.6)
    # Mean
    updateCheckboxInput(session, "statsMean", value = FALSE)
  })
  
  
  # Generate the plot code based on input options but do not evaluate yet.
  plotCode <- reactive({createPlot(input)})
  
  # labelsVector <- reactive({
  #   if (input$statistics) {
  #     if (!is.null(input$statsCombinations)) {
  #       labelsVector <- vector(length = length(input$statsCombinations))
  #       statsPairwiseTests <- strsplit(input$statsCombinations, 'vs')
  #       for (i in 1:length(input$statsCombinations)) {
  #         position1 <- statsPairwiseTests[[i]][1]
  #         position2 <- statsPairwiseTests[[i]][2]   
  #         axisPositions <- match(c(position1, position2), 
  #                                input$filterColumns)
  #         labelsVector[i] <- round(max(processedData()$df()$value)) * ((abs(axisPositions[1]-axisPositions[2])*0.05)+1)
  #       }
  #     }
  #   }
  # })
  # 
  
  # Evaluate the code based on the processed data.
  plotFigure <- reactive({
    plotData <- processedData()$df()
    eval(parse(text = glue(plotCode())))
  })
  
  # Render the plot.
  output$rainCloudPlot <- renderPlot({
    # We don't render the plot without inputData.
    req(inputData$name())
    plotFigure()},
    height = function(x) input$height,
    width = function(x) input$width)
  
  # ScriptCode
  scriptCode <- reactive({
    formatCode(input, inputData$code(), processedData()$code(), plotCode())
  })
  
  # Print the code.
  output$rainCloudCode <- renderText({
    # We don't render the code without inputData.
    req(inputData$name())
    scriptCode()
  })
  
  # Print the data
  output$rainCloudDataSummary <- renderPrint({
    # We don't render the table without inputData.
    req(inputData$name())
    summary(processedData()$df())
  })
  
  output$rainCloudData <- renderTable({
    # We don't render the table without inputData.
    req(inputData$name())
    inputData$inputData()
  })
  
  # Download button
  output$downloadPlot <- downloadHandler(
    filename = function() {
      # rainCloudPlot-inputdata.txt.pdf
      paste(paste('rainCloudPlot-',inputData$name(), sep = ""), 
            input$downloadFormat, sep = ".")
    },
    content = function(file) {
      if(input$downloadFormat == 'tiff') {
        ggsave(file,
               plot = plotFigure(),
               device = input$downloadFormat,
               # Width and height are in inches. We increase the dpi to 300, so we
               # have to divide by 72 (original default pixels per inch) 
               width = input$width / 72,
               height = input$height / 72,
               compression = "lzw",
               units = "in",
               dpi = 300)
      } else {
        ggsave(file,
               plot = plotFigure(),
               device = input$downloadFormat,
               # Width and height are in inches. We increase the dpi to 300, so we
               # have to divide by 72 (original default pixels per inch) 
               width = input$width / 72,
               height = input$height / 72,
               units = "in",
               dpi = 300)
      }
    }
  )
  
  # callModule(downloadPlot, id = "rainCloudDownload",
  #            plot = plotFigure(),
  #            fileName = inputData$name(),
  #            width = input$width / 72,
  #            height = input$height / 72)
  
  # Download zip file with script, data, and plots.
  output$downloadZip <- downloadHandler(
    filename = function() {
      paste0("RainCloudPlot-", inputData$name(), ".zip")
    },
    content = function(fname) {
      fileList <- c()
      tmpdir <- tempdir()
      # Copy inputData to tmpDir
      file.copy(from = c(inputData$datapath()),
                to = tmpdir)

      # Copy halfViolinPlots.R to tmpDir
      file.copy(from = c("source/halfViolinPlots.R"), 
                to = tmpdir)
      
      # Move to the tmpDir to work with the tmpFiles
      wd = getwd()
      setwd(tmpdir)
      
      # Change the name of the uploaded file so that the code still works.
      tmpInputFile <- basename(inputData$datapath())
      file.rename(from = tmpInputFile,
                  to = inputData$name())
    
      # Code
      write(scriptCode(), "rainCloudPlot.R")

      fileList <- c(fileList, inputData$name(), "rainCloudPlot.R", "halfViolinPlots.R")
      
      # Create all images (except tiff that is compressed).
      for (format in c('pdf','svg','eps','png')) {
        file <- paste(paste0('rainCloudPlot-',inputData$name()),
                      format, sep = ".")
        ggsave(file,
               plot = plotFigure(),
               device = format,
               width = input$width / 72,
               height = input$height / 72,
               units = "in",
               dpi = 300)
        fileList <- c(fileList, file)
      }
      
      # Add compressed .tiff
      tiffFile <- paste(paste0('rainCloudPlot-',inputData$name()),
                        'tiff', sep = ".")
      ggsave(tiffFile,
             plot = plotFigure(),
             device = 'tiff',
             compression = "lzw",
             width = input$width / 72,
             height = input$height / 72,
             units = "in",
             dpi = 300)
      fileList <- c(fileList, tiffFile)
      
      # And create the zip
      zip(zipfile=fname, files=fileList)
      setwd(wd)
    },
    contentType = "application/zip"
  )
}
