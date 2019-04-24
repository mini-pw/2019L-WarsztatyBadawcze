genie <- function(X, k, g){
  ### Funkcja dokonuje klasteryzacji punktow z przestrzeni R^d za pomoca algorytmu analizy skupien Genie
  # Wejscie: X - macierz liczbowa n x d, gdzie n-ty wiersz zawiera wspolrzedne n-tego punktu z przestrzeni R^d
  #          k - dana z gory liczba calkowita dodatnia klastrow, na jakie funkcja ma podzielic punkty
  #          g - prog, liczba z przedzialu (0,1]
  # Wyjscie: z - wektor z przestrzeni {1,2,...,k}^n, ktorego n-ty element zawiera informacje o klastrze, do ktorego nalezy n-ty punkt
  stopifnot(is.numeric(X), is.matrix(X), is.finite(X))
  stopifnot(is.numeric(k), length(k) == 1, is.finite(k), k>0, floor(k)==k, k<=dim(X)[1])
  stopifnot(is.numeric(g), length(g) == 1, is.finite(g), g>0, g<=1)
  
  n <- dim(X)[1]
  z <- 1:n #wektor n-elemetnowy, informujacy do ktorego klastra nalezy n-ty punkt; inicjalnie kazdy punkt ma wlasny klaster
  ce <- rep(1, n) #wektor informujacy, jaka jest licznosc kazdego z klastrow; c[i] to licznosc klastra o numerze i
  M <- mst(X) #macierz przechowujaca krawedzie minimalnego drzewa rozpinajacego punkty z X
  
  for(j in 1:(n-k)){
    if(j == 1) new_gini <- 0
    else new_gini <- gini_cumulative(new_gini, ce_prev, ce_prev[u], ce_prev[v], n) #wyliczamy indeks Giniego metodą kumulatywna - w zaleznosci od indeksu w poprzedniej iteracji
    if(new_gini < g){   #jesli gini(ce) <g, bierzemy najtansza krawedz
      if(is.vector(M)) edge <- M
      else{
        edge <- M[1,]
        M <- M[-1,] #usuwamy krawedz z niewykorzystanych
      }         
    }else{ # w.p.p. bierzemy najtansza krawedz sposrod tych, ktorych koniec lezy w najmniej licznym klastrze
      ind <- which(ce == min(ce))
      
      beg <- z[M[,1]] %in% ind
      end <- z[M[,2]] %in% ind
      
      t <- M[beg | end, ]
      if(is.vector(t)) edge <- t
      else edge <- t[1, ]
      M <- M[-(which(beg | end)[1]),] #usuwamy krawedz z niewykorzystanych
    }
    u <- min(z[edge])
    v <- max(z[edge])
    
    ce_prev <- ce
    ce[u] <- ce[u] + ce[v] #scalamy dwa klastry, zlaczamy licznosci, przesuwamy cala reszte
    ce[v:(n-j+1)] <- ce[(v+1):(n-j+2)]
    ce <- ce[-(n-j+1)] 
    
    z[z == v] <- u
    z[z > v] <- z[z > v] -1
  }
  z # zwracamy z
}

gini <- function(ce){
  ### Funkcja zwraca indeks Giniego ciagu liczb calkowitych ce
  # Wejscie: ce - wektor liczb calkowitych o dlugosci co najmniej 2
  # Wyjscie: nieobciazony indeks Giniego ciagu
  stopifnot(is.numeric(ce), is.atomic(ce))
  stopifnot(length(ce)>1, floor(ce)==ce)
  stopifnot(is.finite(ce), ce > 0)
  s <- 0 #inicjalizacja sumy
  m <- length(ce) 
  for(i in 1:(m-1)) s <- s+ sum(abs(ce[i]-ce[(i+1):m])) #obliczenie licznika wzoru na indeks
  s/((m-1)*sum(ce)) #zwrocenie indeksu
}

gini_cumulative <- function(gini_prev, ce, ce_u, ce_v, n){
  ### Funkcja oblicza indeks Giniego ciagu ce', kiedy znamy indeks ciagu ce oraz zachodzi:
  ###      sum(ce) == sum(ce') == n,
  ### a ponadto ciag ce' powstal przez dodanie do wyrazu ce_u wyrazy ce_v i usuniecie wyrazu ce_v
  # Wejscie: gini_prev - wartosc indeksu Giniego dla ciagu ce
  #          ce - ciag, dla ktorego znamy wartosc indeksu Giniego
  #          ce_u - element ciagu ce, do ktorego dodajemy ce_v
  #          ce_v - element ciagu ce, ktory dodajemy do ce_u, a nastepnie usuwamy
  #          n - stala suma ce = suma ce'
  # Wyjscie: indeks giniego dla zmodyfikowanego ciagu
  m <- length(ce)
  (gini_prev*(m-1) + ((sum(abs(ce-ce_u-ce_v))-ce_u-ce_v) - (sum(abs(ce-ce_u))+sum(abs(ce-ce_v))-abs(ce_u-ce_v)))/n )/(m-2)
}

mst <- function(X){
  # Funkcja zwraca krawedzie minimalnego drzewa rozpinajacego graf G utworzonego z punktow przekazanych w macierzy jako argument
  # Wejscie - X - macierz liczbowa n x d zawierajaca wspolrzedne n punktow w przestrzeni R^d
  # Wyjscie macierz liczb calkowitych (n-1) x 2, ktorej kazdy wiersz oznacza jedna z krawedzi minimalnego drzewa rozpinajacego
  #         krawedzie sa posortowane w kolejnosci od najkrotszej do najdluzszej
  
  stopifnot(is.matrix(X), is.numeric(X), all(is.finite(X))) #sprawdzenie warunkow wejsciowych
  n <- dim(X)[1]
  d <- dim(X)[2]
  
  
  F <- rep(Inf, n) # F[i] oznacza indeks punktu najblizszego do punktu o numerze i; inicjalnie +Inf
  D <- rep(Inf, n) # D[i] oznacza odleglosc punktu i od punktu F[i]; inicjalnie +Inf
  
  lastj = 1;  # zmienna do przechowywania ostatniego wierzcholka dodanego do drzewa - zaczynamy od pierwszego
  W <- matrix(NA, nrow = n-1, 3) # macierz wyjsciowa
  M <- 2:n # numery punktow jeszcze nie dodanych do drzewa
  for(i in 1:(n-1)){
    bestj = 1; # zmienna do oznaczania numeru najlepszego kandydata na dodanie do drzewa
    if(!is.matrix(X[M,])){  # tworzymy wektor d odleglosci X[lastj, ] od wszystkich wierzcholkow jeszcze nie dodanych
      d = distance(X[M,], X[lastj,])
    }else d = apply(X[M,], 1, function(x) distance(x, X[lastj,]))
    ind = d<D[M] #indeksy tych punktow, ktorych odleglosc od rozpatrywanego teraz punktu X[lastj, ] jest mniejsza niz dotychczasowe minimum
    D[M][ind] <- d[ind] #ustawienie nowych odleglosci i indeksow najblizszych wierzcholkow
    F[M][ind] <- lastj
    assertthat::are_equal(D[1], Inf) #upewniamy sie, ze D[1] pozostaje +Inf
    m <- which(D == min(D[M]))
    bestj = m[m %in% M][1] #szukamy najlepszego kandydata na dodanie do drzewa - wierzcholek najbliszy do ktoregokolwiek z wierzcholkow dodanych juz do drzewa
    W[i,] <- c(F[bestj], bestj, D[bestj]) # dodanie nowej krawedzi do drzewa
    M <- M[M != bestj] #usuniecie wierzcholka z listy niedodanych
    lastj <- bestj #aktualizacja indeksu ostatnio dodanego wierzcholka
  }
  apply(W, 1, function(x) if(x[1] > x[2]) x[c(1,2)] <- x[c(2,1)]) #upewniamy sie, ze dla kazdej krawedzi xy x<y
  W[order(W[,3]),1:2] #zwracamy krawedzie drzewa posortowane wedlug dlugosci
}

distance <- function(x, y){
  ### Funkcja liczy odleglosc euklidesowa w metryce R^d dwoch punktow
  # Wejscie: x, y - wektory wspolrzednych punktow
  # Wyjscie: odleglosc miedzy tymi punktami (norma euklidesowa wektora x-y)
  sum((x-y)**2)**(1/2)
}
