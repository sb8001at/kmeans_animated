navbarPage(
  theme = shinytheme("united"),  
  # Application title
  "k-meansのイメージ", 
  
  tabPanel(
    "k-means",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          fluidPage(
            column(6, 
                   numericInput("n_points", label="データ数", value=500, min=100, max=2000, step=50),
                   br(),
                   br(),
                   actionButton("initialize", label="データの初期化") 
            ),
            
            column(6, 
                   numericInput("ncluster", label="クラスターの数", value=3, min=3, max=10, step=1),
                   br(),
                   br(),
                   actionButton("runculc", label="実行") 
            )
          ),
          br(),
          tags$footer(
            br(),
            br(),
            tags$a(href="https://github.com/sb8001at/kmeans_animated", "sb8001at/kmeans_animated"),
            tags$a(href = "https://github.com/sb8001at/kmeans_animated", icon("github")),
            br(),
            br(),
            tags$a(href = "https://creativecommons.org/licenses/by-nc-sa/4.0/deed.ja", tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/1/12/Cc-by-nc-sa_icon.svg", width="10%")),
            br(),
            tags$a(href = "https://creativecommons.org/licenses/by-nc-sa/4.0/deed.ja", "クリエイティブ・コモンズ CC BY-NC-SA"),
            tags$p("に従い，複製、頒布、展示、実演を行うにあたり、著作権者の表示を要求し、非営利目的での利用に限定し、作品を改変・変形・加工してできた作品についても、元になった作品と同じライセンスを継承させた上で頒布を認めます。"),
            br(),
            tags$p("Rから以下のコードで実行すると、ローカルPCで動かすことができます。"),
            tags$p(code("if(require(shiny)){install.packages(\"shiny\")};runGitHub(\"kmeans_animated\", \"sb8001at\")"))
          )
        ),
        
        mainPanel(
          div(
            plotlyOutput("kmeansplot", height="800px") %>% withSpinner(color="#0dc5c1")
          )
        )
      )
    )
  ),
  tabPanel(
    "説明",
    h2("このアプリケーションについて"),
    p("このShinyアプリは、k-meansによるクラスタリングのイメージを表現するために作成したものです。
      以下のように、すでに先人がD3.jsで実装されているものを、Shiny＋Plotlyで作成したものです。"),
    br(),
    a(href = "http://tech.nitoyon.com/ja/blog/2013/11/07/k-means/", "K-means 法を D3.js でビジュアライズしてみた"),
    br(),
    br(),
    p("Plotlyでの色の調整と線分のサイズ調節が難しく、先人ほど良い出来にはなっていません。"),
    p("クラスター数とデータ数を初期化し、その後実行すれば、plotlyのアニメーションとしてクラスタリングの過程を追うことができます。")
  )
)
