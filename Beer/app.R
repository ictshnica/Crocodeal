#    http://shiny.rstudio.com/

#library(jsonlite)
#library(stringr)
#library(dplyr)


library(dplyr)
library(recommenderlab)
library(reshape2)
library(ggplot2)


recommend <- function(scores) {
  
  # отбросили пропуски
  scores = na.omit(scores)
  
  # конвертируем колонки -- приводим к нужному типу
  scores$overall = as.numeric(scores$overall)
  scores$member_url = as.factor(scores$member_url)
  scores$style = as.factor(scores$style)
  
  lasUserId <- length(unique(scores$member_url)) + 1
  
  message("lasrUserId", lasUserId)
  
  # строим разреженную матрицу на основе зачитанных оценок
  scores2 = sparseMatrix(as.integer(scores$member_url), as.integer(scores$style), x = scores$overall)
  
  rev <- as(scores2, "realRatingMatrix")
  
  # ищем ближайших пользователей
  similarity_users50 <- similarity(rev[1:50, ], method = "cosine", which = "users")
  
  # as.matrix(similarity_users50)
  # image(as.matrix(similarity_users50), main = "User similarity")
  
  ratings_beers <- rev[rowCounts(rev) > 1,  colCounts(rev) > 2] 
  # ratings_beers
  
  average_ratings_per_user <- rowMeans(ratings_beers)
  
  # ggplot() + geom_histogram(aes(x=average_ratings_per_user)) + ggtitle("Распределение средних оценок пользователей")
  # ggplot(scores, aes(style))+ geom_bar()+ theme(axis.text.x = element_text(angle=60, hjust=1))
  
  set.seed(100)
  
  test_ind <- sample(1:nrow(ratings_beers), size = nrow(ratings_beers)*0.2)
  recc_data_train <- ratings_beers[-test_ind, ]
  recc_data_test <- ratings_beers[test_ind, ]
  
  recc_model <- Recommender(data = recc_data_train, method = "IBCF",  parameter = list(k = 30))
  # recc_model
  
  recc_predicted <- predict(object = recc_model, newdata = recc_data_test, n = 3)
  # recc_predicted
  
  recc_user_1 <- recc_predicted@items[[2]]
  # recc_user_1
  
  # beers_user_1 <- recc_predicted@itemLabels[recc_user_1]
  # beers_user_1
  
  # message(recc_predicted)
  message(recc_user_1)
  
  recc_user_1
}


#j = readLines("~/Projects/Crocodeal/Crocodeal/beers.jsonlines") %>% 
#  str_c(collapse = ",") %>%  
#  (function(str) str_c("[", str, "]")) %>% 
#  fromJSON(simplifyDataFrame = T)
#j<-na.omit(j)

# залили датасет
scores = read.csv("~/HELL/Crocodeal/Beer/scores.csv", header=TRUE)

scores$X = NULL

# задали дефолтного пользователя
userId = "YOU"

# отбросили пропуски
scores = na.omit(scores)

# конвертируем колонки -- приводим к нужному типу
scores$overall = as.numeric(scores$overall)
scores$member_url = as.factor(scores$member_url)
scores$style = as.factor(scores$style)

updatedScores <- scores

print(scores[1,])

chosenBeersList <- c("Belgian Dark Ale",
                     "American Amber / Red Ale",
                     "American Brown Ale",  
                     "American Double / Imperial Stout", 
                     "American Porter",
                     "American Strong Ale")

## app.R ##
library(shinydashboard)
library(shiny)

## Сайт, где мы брали информацию и туториалы
# https://rstudio.github.io/shinydashboard/structure.html
# http://deanattali.com/blog/building-shiny-apps-tutorial/

ui <- dashboardPage(
  
  dashboardHeader(title = "Думаешь, ты пробовал все? Тогда тебе к нам..."),
  
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Параметры напитка", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Оценка различных видов пива", tabName = "widgets", icon = icon("th")),
      menuItem("Три предложения", tabName = "beer", icon = icon("th"))
    )
  ),
  
  ## Body content
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                column(width = 7,
                       box(
                         title = "Определите крепость желаемого напитка",
                         width = 0.25,
                         sliderInput("slider", "градусы:", value = c(0.25, 14.75), min = 0.25, max = 14.75),
                         "Как известно, все алкогольные напитки различаются по градусам. Если для вас важна крепость пива, 
                         вы можете выбрать её двигая слайдеры, если же этот параметр для вас не важен - переместите слайдеры на минимальное и максимальное значение"
                       ),
                       actionButton("button", "Завершить")
                       )
              )
              ),
      
      
      # Second tab content
      tabItem(tabName = "widgets",
              fluidRow(
                column(width = 7,
                       box(
                         title = "Оцените предложенное пиво",
                         width = 0.9,
                         sliderInput("slider2", chosenBeersList[1], 1, 5, 3),
                         "ОПИСАНИЕ ПИВА"
                       ),
                       box(
                         title = "Оцените предложенное пиво",
                         width = 0.9,
                         sliderInput("slider3", chosenBeersList[2], 1, 5, 3),
                         "ОПИСАНИЕ ПИВА"
                       ),
                       box(
                         title = "Оцените предложенное пиво",
                         width = 0.9,
                         sliderInput("slider4", chosenBeersList[3], 1, 5, 3),
                         "ОПИСАНИЕ ПИВА"
                       ),
                       box(
                         title = "Оцените предложенное пиво",
                         width = 0.9,
                         sliderInput("slider5", chosenBeersList[4], 1, 5, 3),
                         "ОПИСАНИЕ ПИВА"
                       ),
                       box(
                         title = "Оцените предложенное пиво",
                         width = 0.9,
                         sliderInput("slider6", chosenBeersList[5], 1, 5, 3),
                         "ОПИСАНИЕ ПИВА"
                       ),
                       box(
                         title = "Оцените предложенное пиво",
                         width = 0.9,
                         sliderInput("slider7", chosenBeersList[6], 1, 5, 3),
                         "ОПИСАНИЕ ПИВА"
                       ),
                       # box(
                       #   title = "Ваши оценки",
                       #   tableOutput("userScores")
                       # )  ,
                       # box(
                       #   title = "Рекомендованные виды пива",
                       #   tableOutput("recommendedBeer")
                       # )                       ,
                       # box(
                       #   title = "Последние 3 элемента в датасете",
                       #   tableOutput("last3elements")
                       # ),
                       actionButton("button2", "Завершить")
                )
              )
      ),
      #Third tab
      tabItem(tabName = "beer",
              fluidRow(
                box(
                  title = "Все еще уверен, что мы не сможем тебя удивить? Тогда вот идеальное предложение для тебя...",
                  tableOutput("recommendedBeer")
                )
              )
      )
      )
    )
)




server <- function(input, output, session) {
  
  
  # Reactive expression to compose a data frame containing filtered values
  scoresValues <- reactive({
    newscores <- scores[scores$avg2>input$slider[1]&scores$avg2<input$slider[2],]
    newscores
  })
  
  # Show the values using an HTML table
  output$scores <- renderTable({
    scoresValues()
  })
  
  bestRecommendations <- reactive({
    
    print("Running beer recommendations...")
    
    oldScores <- scoresValues()
    
    message("Len of old ", nrow(oldScores))
    message("Head of old ", oldScores[1,])
    
    # формируем датафрейм из пользовательских оценок разному пиву со страницы
    beersRatings <- 
      data.frame(
        c(userId, userId, userId, userId, userId, userId),
        chosenBeersList,
        c(input$slider2[1], input$slider3[1], input$slider4[1], 
          input$slider5[1], input$slider6[1], input$slider7[1]),
        c(0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        fix.empty.names = FALSE
      )
    
    colnames(beersRatings) <- colnames(oldScores)
    updatedScores <- rbind(oldScores, beersRatings)
    # n <- nrow(updatedScores)
    recommended <- recommend(updatedScores)
    print(recommended)
    recommended
  })
  
  output$recommendedBeer <-  renderTable({
    bestRecommendations()
  })
  
  
  observeEvent(
    input$button2, {
      
      print(bestRecommendations())      
      message(bestRecommendations())
      
      newtab <- switch(input$tabs, "beer" = "widgets", "widgets" = "beer")
      updateTabItems(session, "tabs", newtab)
      
      # newtab <- switch(input$tabs,
      #                  "widgets" = "beer",
      #                  "beer" = "widgets"
      # )
      # updateTabItems(session, "tabs", newtab)
      # # updateTabItems(session, "tabs", input$tabs)
      # oldScores <- scoresValues()
      # message("len of old ", nrow(oldScores))
      # message("head of old ", oldScores[2,])
      # 
      # beersRatings <- data.frame(
      #   #                                                        member_url                    style overall  avg2
      #   #  https://www.beeradvocate.com/community/members/tillmac62.756934/ American Amber / Red Ale       4 4.035
      #   c(userId,userId,userId,userId,userId,userId),
      #   c("Belgian Dark Ale","American Amber / Red Ale","American Brown Ale",  
      #     "American Double / Imperial Stout",  "American Porter", "American Strong Ale"),
      #   c(input$slider2[1], input$slider3[1], input$slider4[1], 
      #     input$slider5[1], input$slider6[1], input$slider7[1]),
      #   c(0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
      #   fix.empty.names = FALSE
      # )
      # 
      # colnames(beersRatings) <- colnames(oldScores)
      # 
      # print(beersRatings)
      # 
      # updatedScores <- rbind(oldScores, beersRatings)
      # 
      # n <- nrow(updatedScores)
      # print(updatedScores[(n-10):n, ])
      # 
      # recommended <- recommend(updatedScores)
      # print(recommended)
    }
  )
  
  # userScores <- reactive({
  #   
  #   df <- data.frame(
  #     c(input$slider2$label, input$slider3$label, input$slider4$label, input$slider5$label, input$slider6$label, input$slider7$label),
  #      c(input$slider2[1], input$slider3[1], input$slider4[1], input$slider5[1], input$slider6[1], input$slider7[1]),
  #     fix.empty.names = FALSE)
  # 
  #   # df
  # })  
  # 
  # output$userScores <- renderTable({
  #   message("Setting userScores")
  #   userScores()
  # })
  
  # output$last3elements <- renderTable({
  #   message("Setting last3elements")
  #   df <- scoresValues()
  #   n <- nrow(df)
  #   df[(n - 2):n, ]
  # })
  observeEvent(
    input$button, {
      newtab <- switch(input$tabs, "dashboard" = "widgets", "widgets" = "dashboard")
      updateTabItems(session, "tabs", newtab)
    }
  )
  
  # observeEvent(
  #   input$button2, {
  #     message("Button Two clicked, yeah! ", input$button2)
  #     updateTabItems(session, "tabs", input$tabs)
  #   }
  # )
}


shinyApp(ui, server)