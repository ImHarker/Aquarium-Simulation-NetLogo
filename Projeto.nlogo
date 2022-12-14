globals [AvgWaterQuality FoodEaten FoodDestroyed Nascimentos Mortes MortesAge FishEaten]
breed [comidas comida]
breed [plantas planta]
breed [peixes1 peixe1]
breed [peixes2 peixe2]
breed [mortos morto]
breed [tubaroes tubarao]
breed [peixes3 peixe3]
peixes1-own[canBreed age hp dieAge breedCD]
peixes2-own[canBreed age hp dieAge breedCD]
peixes3-own[canBreed age hp dieAge breedCD eatCD]
tubaroes-own[canBreed age hp dieAge breedCD]
mortos-own[decay]
patches-own [quality] ;qualidade = 100 - lixo
comidas-own [decay]

to Setup
  clear-all

  if AvgAgeEspecie1 <= MinBreedAgeEspecie1 or AvgAgeEspecie2 <= MinBreedAgeEspecie2[
    user-message "A idade mínima para reprodução é demasiado elevada! Os peixes não se vão reproduzir!"
  ]

  create-plantas  3 + random 4[
    set shape "plant"
    set size 5
    set color green
    setxy (32 - (random 64)) ((random 13) - 30)
  ]

  create-peixes1 Especie1[
    set color red
    setxy random-pxcor random-pycor
    set heading random 360
    set size 1.5
    set shape "fish"

    set dieAge  avgAgeEspecie1 + (random avgAgeEspecie1 / 3) - avgAgeEspecie1 / 6
    set hp 100
  ]

  create-peixes2 Especie2[
    set color yellow
    setxy random-pxcor random-pycor
    set heading random 360
    set size 1.5
    set shape "fish"

    set dieAge  avgAgeEspecie2 + (random avgAgeEspecie2 / 3) - avgAgeEspecie2 / 6
    set hp 100
  ]

  create-peixes3 5 + random 5[
  set color pink
    setxy random-pxcor random-pycor
    set heading random 360
    set size 1.5
    set shape "fish 2"

    set dieAge  50 + (random 50 / 3) - 50 / 6
    set hp 100
  ]

  create-tubaroes 5 + random 5[
  set color gray
    setxy (32 - (random 64)) ((random 13) - 30)
    set heading random 360
    set size 3
    set shape "shark"

    set dieAge  50 + (random 50 / 3) - 50 / 6
    set hp 200
  ]

  ask patches [
    set pcolor 96
    set quality 100
    if pycor < 15 - 32[
      set pcolor yellow - 0.6
    ]
  ]
  reset-ticks
end

to Go
  set AvgWaterQuality 0
  if count turtles with [breed != comidas and breed != plantas and breed != mortos] = 0 [
    user-message "Todos os peixes morreram"
    stop
  ]

  ;;Dano
  ask turtles with [breed != comidas and breed != plantas and breed != mortos] [
    if hp <= 0 [
      set Mortes Mortes + 1
      hatch-mortos 1[
        set color gray
        set heading 180
        set shape "fish"
        set decay 100 * size  + (random 100) - 50
      ]
      die
    ]
    if age >= dieAge [
      set MortesAge MortesAge + 1
      set Mortes Mortes + 1
      hatch-mortos 1[
        set color gray
        set heading 180
        set shape "fish"
        set decay 100 * size + (random 100) - 50
      ]
      die
    ]
    let thisquality [quality] of patch-here
    ifelse thisquality > 100[
      set thisquality 100
      ] [ if thisquality < 0[
        set thisquality 0
      ]
    ]
    ifelse breed != tubaroes[
      set hp hp - (DmgTick * (3 - (thisquality / 50 )))
    ][if ticks > 2000[set hp hp - (DmgTick * (3 - (thisquality / 50 )))]]
    ;;Incrementa Age
    if ticks mod TicksPerAge = 0 [
      set age age + 1
    ]




    ;;muda posiçao

    if random-float 1 < 0.1[
      set heading heading - 45 + random 90
    ]

    if pxcor = 32 or pxcor = -32 or pycor = 32 or pycor = -32[
      set heading random 360
    ]

    if breed = tubaroes[
      if pycor >= (13 - 30)[
        set heading 180
      ]
    ]

    ;;comer
    if breed != peixes3[
    if count comidas-here != 0[
      ask one-of comidas-here[die]
      set size size + 0.1
      set hp hp + 25
      ifelse breed != tubaroes[
      if hp > 100 [ set hp 100]
      ][if hp > 500 [set hp 500]]

      set FoodEaten FoodEaten + 1
      if BreedCD <= 0[
        set canBreed 1
      ]
    ]
    ]
    if breed = tubaroes[
      if count mortos-here != 0[
        ask one-of mortos-here[die]
        set size size + 0.2
        set hp hp + 50
        if hp > 500 [set hp 500]
        if BreedCD <= 0[
          set canBreed 1
        ]
      ]
    ]
    if breed = peixes3[
      set eatCD eatCD - 1

        if count comidas-here != 0[
      ask one-of comidas-here[die]
      set size size + 0.025
      set hp hp + 25
      if hp > 100 [ set hp 100]
      set FoodEaten FoodEaten + 1
      if BreedCD <= 0[
        set canBreed 1
      ]
    ]


      if eatCD <= 0[
        let thissize size
        if count turtles-here with [breed = peixes2 or breed = peixes1] != 0[
          let target one-of turtles-here with [breed = peixes2 or breed = peixes1]
          if thissize >= [size] of target  [
              set size size + 0.15
              set hp hp + 50
              if hp > 100[set hp 100]
            set eatCD 250 + random 250
            set Mortes Mortes + 1
              set FishEaten FishEaten + 1
              if BreedCD <= 0[
              set canBreed 1
              ask target[
              die
              ]

            ]
          ]
        ]
      ]
    ]

    ;;reproduzir
    set BreedCD BreedCD - 1
    let thisbreed breed
    let thiswho who
    let targ (one-of (turtles-here with [who != thiswho and breed = thisbreed and breed != comidas and breed != plantas and breed != mortos] ))
    if targ != nobody[
    if( [canBreed] of targ = 1 and canBreed = 1)[
        if breed = peixes1 and age >= MinBreedAgeEspecie1 and [age] of targ >= MinBreedAgeEspecie1 [
          BreedF self targ
        ]
        if breed = peixes2 and age >= MinBreedAgeEspecie2 and [age] of targ >= MinBreedAgeEspecie2 [
          BreedF self targ
        ]
        if breed = tubaroes and age >= 10 and [age] of targ >= 10 [
          BreedF self targ
        ]
        if breed = peixes3 and age >= 3 and [age] of targ >= 3 [
          BreedF self targ
        ]
  ]
    ]
    fd 1
  ]

  ;;movimento comida
  ask comidas[
    if pycor != -32[
      if ticks mod (random 10 + 1) = 0  [
        set heading one-of[ 135 180 225]
        fd 1
      ]
    ]

    ;;destruir comida
    if decay = 0[
      ask patch-here[
        set quality quality - Pol_Comida
        PatchColor self

      ]
      set FoodDestroyed FoodDestroyed + 1
      die
    ]
    set decay decay - 1
  ]

  ;;call
  PlantF
  MortosF
  SpreadWaterQuality
  BombaAgua
  KillPlant

  ;;CA media
  ask patches[    set AvgWaterQuality AvgWaterQuality + quality ]


  ;;fix water every 50t
  if ticks mod 50 = 0[
    ask patches with [quality < 0] [

      let a quality
      set quality 0
      let  p patch-at 0 (32 - pycor)
      ask p[
        set quality quality + a
      ]

    ]
  ]


  ;;calcula media
  set AvgWaterQuality AvgWaterQuality / (count patches)


  ;;agua poluida
  if AvgWaterQuality < 0[
    ask patches[set pcolor 90 set quality 0]
    set AvgWaterQuality 0
    ;;user-message "Toda a agua do aquario esta poluida"
    ;;stop
  ]

;;alimentar
  if random (100 - Feed_Prob_Per_Tick) = 0[
    Feed
  ]

  tick
end



to Feed

  create-comidas Qtd_Comida [
    setxy random-pxcor 32
    set heading one-of[ 135 180 225]
    set color white
    set size 1.5
    set shape "dot"
    set decay 50 + random 150
  ]

end

to SpreadWaterQuality
  ask patches [


    if quality <= 99[
; baixo
      let p (patch-at 0 -1)
      if  pycor != -32 and ([quality] of p) > (quality - 1) and ([quality] of p) >= 1 [
        set quality quality + 1
        PatchColor self
        ask p[
          set quality quality - 1
          PatchColor self
        ]
      ]

      ; esquerda baixo
      set p (patch-at -1 -1)
      if  pycor != -32 and pxcor != -32 and ([quality] of p) > (quality - 1) and ([quality] of p) >= 1[
        set quality quality + 1
        PatchColor self
        ask p[
          set quality quality - 1
          PatchColor self
        ]
      ]

      ; direita baixo
      set p (patch-at 1 -1)
      if  pycor != -32 and pxcor != 32 and ([quality] of p) > (quality - 1) and ([quality] of p) >= 1[
        set quality quality + 1
        PatchColor self
        ask p[
          set quality quality - 1
          PatchColor self
        ]
      ]

      ; esquerda
      set p (patch-at -1 0)
      if  pxcor != -32 and ([quality] of p) > (quality + 1) and ([quality] of p) >= 1[
        set quality quality + 1
        PatchColor self
        ask p[
          set quality quality - 1
          PatchColor self
        ]
      ]

      ; direita
      set p (patch-at 1 0)
      if  pxcor != 32 and ([quality] of p) > (quality + 1) and ([quality] of p) >= 1[
        set quality quality + 1
        PatchColor self
        ask p[
          set quality quality - 1
          PatchColor self
        ]
      ]

      ; cima
      set p (patch-at 0 1)
      if  pycor != 32 and ([quality] of p) > (quality + 2) and ([quality] of p) >= 1[
        set quality quality + 1
        PatchColor self
        ask p[
          set quality quality - 1
          PatchColor self
        ]
      ]
      ;esquerda cima
      set p (patch-at -1 1)
      if pxcor != -32 and pycor != 32 and ([quality] of p) > (quality + 2) and ([quality] of p) >= 1[
        set quality quality + 1
        PatchColor self
        ask p[
        set quality quality - 1
          PatchColor self
        ]
      ]

                  ;direita cima
      set p (patch-at 1 1)
      if pxcor != 32 and pycor != 32 and ([quality] of p) > (quality + 2 ) and ([quality] of p) >= 1[
        set quality quality + 1
        PatchColor self
        ask p[
          set quality quality - 1
          PatchColor self
        ]
      ]

    ]

  ]
end


;;Bomba de agua

to BombaAgua
  if BombaDeAgua = true[
  if ticks mod (101 - PurifyRate) = 0[
      ask patches with [ ( (abs( pxcor ) = 32) or  (abs ( pxcor ) = 31)) and (pycor = -32 or pycor = -31)][
        set quality quality + ((100 - quality) * PurifyAmount)
      ]
    ]
  ]
end


;;reproduçao

to BreedF [this targ]
  ask targ[
    set canBreed 0
    set BreedCD BreedCooldown
  ]
  ask this [
    set canBreed 0
    ifelse breed != tubaroes[
    set BreedCD BreedCooldown
    ][set BreedCD 250]
    if breed = peixes3[
      set BreedCD 500
    ]
  ]
  if breed = tubaroes and count tubaroes > 20 [stop]
  if breed = peixes3 and count peixes3 > 15 [stop]
  if random (100 - Prob_Nascer) = 0[
    hatch 1 [
      set age 0
      ifelse breed != tubaroes[
        set size 1.5
        set hp 100
      ][set hp 200 set size 3]
      set Nascimentos Nascimentos + 1
      set BreedCD 0
    ]
  ]

end

;;cor de fundo
to PatchColor [this]
  ask this[
    ifelse quality >= 0[ set pcolor 0.06 * quality + 90 ]  [set pcolor 90 ]
    if pcolor > 96[ set pcolor 96]
    if  pycor < 15 - 32[
      ifelse quality >= 0 [ set pcolor 0.044 * quality + 40 ] [set pcolor 40]
    ]
  ]
end

to KillPlant
  ask patches with [quality < 20 and pycor < 15 - 32][
    ask turtles-here with [breed = plantas][die]
  ]
end

to PlantF
  if ticks mod 10 = 0[
    ask plantas[
      ask patch-here[
        ask neighbors [
          set quality  quality + ((100 - quality) * 0.01)
        ]
      ]
    ]
  ]
end

to MortosF
  ask mortos[
    if decay <= 0 [ die ]
    if pycor != -32 [
      if ticks mod (random 10 + 1) = 0  [
        if random-float 1 < 0.2 [
          set heading one-of[ 135 180 225]
        ]
        fd 1
      ]
      ]
    set decay decay - 1
    ask patch-here[
      set quality quality - 0.75
    ]
  ]
end

to Debug
  create-mortos 200[
    set color gray
    setxy (32 - (random 64)) ((random 13) - 30)
    set heading 180
    set size 1.5
    set shape "fish"
    set decay 500
  ]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
13
12
866
866
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-32
32
-32
32
0
0
1
ticks
30.0

BUTTON
899
15
963
48
NIL
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1002
16
1174
49
Especie1
Especie1
0
50
12.0
1
1
NIL
HORIZONTAL

SLIDER
1193
17
1365
50
Especie2
Especie2
0
50
12.0
1
1
NIL
HORIZONTAL

PLOT
1409
10
1873
384
Evolução das Espécies
Ticks
Numero Elementos
0.0
50.0
-5.0
50.0
true
true
"" ""
PENS
"Especie 1" 1.0 0 -2674135 true "" "plot count peixes1"
"Especie 2" 1.0 0 -13345367 true "plot Especie2" "plot count peixes2"
"Tubaroes" 1.0 0 -7500403 true "" "plot count tubaroes"
"Especie 3" 1.0 0 -2064490 true "" "plot count peixes3"

BUTTON
899
114
993
147
NIL
Feed\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
899
67
962
100
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1002
66
1175
99
Qtd_Comida
Qtd_Comida
1
250
60.0
1
1
NIL
HORIZONTAL

PLOT
1410
405
1874
769
Variação da Comida
Ticks
Quantidade Comida
0.0
50.0
-5.0
50.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count comidas"

PLOT
955
405
1392
769
Variação da Qualidade Média da Água
Ticks
Qualidade Media da Agua
0.0
100.0
-5.0
105.0
true
false
"" ""
PENS
"default" 1.0 0 -13840069 true "" "plot AvgWaterQuality"

BUTTON
899
158
966
191
NIL
Debug\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1193
67
1365
100
Pol_Comida
Pol_Comida
10
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
1002
114
1175
147
Feed_Prob_Per_Tick
Feed_Prob_Per_Tick
0.05
100
1.75
0.05
1
NIL
HORIZONTAL

PLOT
1899
405
2337
769
Taxa de Aproveitamento de Comida
Ticks
Taxa (FoodEaten / TotalFood)
0.0
10.0
-0.1
1.1
true
true
"" ""
PENS
"Taxa" 1.0 0 -16777216 true "" "plot ((FoodEaten + 1) / (FoodDestroyed + FoodEaten + 1))"
"y = 0.5" 1.0 0 -13345367 true "" "plot 0.5"
"y = 1" 1.0 0 -13840069 true "" "plot 1"
"y = 0" 1.0 0 -2674135 true "" "plot 0"

SLIDER
1193
115
1365
148
Prob_Nascer
Prob_Nascer
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
1003
163
1175
196
DmgTick
DmgTick
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1003
349
1175
382
PurifyRate
PurifyRate
0
100
80.0
1
1
NIL
HORIZONTAL

SWITCH
1003
300
1177
333
BombaDeAgua
BombaDeAgua
0
1
-1000

SLIDER
1193
349
1365
382
PurifyAmount
PurifyAmount
0
1
0.75
0.01
1
NIL
HORIZONTAL

SLIDER
1192
300
1365
333
TicksPerAge
TicksPerAge
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
1003
253
1176
286
AvgAgeEspecie1
AvgAgeEspecie1
1
50
40.0
1
1
NIL
HORIZONTAL

SLIDER
1192
253
1365
286
AvgAgeEspecie2
AvgAgeEspecie2
1
50
40.0
1
1
NIL
HORIZONTAL

MONITOR
1909
87
1992
132
NIL
Mortes
17
1
11

MONITOR
1909
143
2049
188
Nascimentos vs Mortes
Nascimentos / Mortes
17
1
11

MONITOR
1909
34
1992
79
NIL
Nascimentos
17
1
11

MONITOR
2012
87
2122
132
Mortes por Idade
MortesAge
17
1
11

SLIDER
1192
163
1365
196
BreedCooldown
BreedCooldown
0
200
25.0
1
1
NIL
HORIZONTAL

SLIDER
1003
209
1176
242
MinBreedAgeEspecie1
MinBreedAgeEspecie1
0
30
3.0
1
1
NIL
HORIZONTAL

SLIDER
1192
209
1365
242
MinBreedAgeEspecie2
MinBreedAgeEspecie2
0
30
3.0
1
1
NIL
HORIZONTAL

MONITOR
1910
265
2053
310
Nº Elementos Especie 1
count peixes1
17
1
11

MONITOR
2063
265
2206
310
Nº Elementos Especie 2
count peixes2
17
1
11

MONITOR
1910
204
2027
249
Nº de Peixes Vivos
count peixes1 + count peixes2
17
1
11

MONITOR
2064
204
2189
249
Nº de Peixes Mortos
count mortos
17
1
11

MONITOR
2146
88
2245
134
Peixes Comidos
FishEaten
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

fish 2
false
0
Polygon -1 true false 56 133 34 127 12 105 21 126 23 146 16 163 10 194 32 177 55 173
Polygon -7500403 true true 156 229 118 242 67 248 37 248 51 222 49 168
Polygon -7500403 true true 30 60 45 75 60 105 50 136 150 53 89 56
Polygon -7500403 true true 50 132 146 52 241 72 268 119 291 147 271 156 291 164 264 208 211 239 148 231 48 177
Circle -1 true false 237 116 30
Circle -16777216 true false 241 127 12
Polygon -1 true false 159 228 160 294 182 281 206 236
Polygon -7500403 true true 102 189 109 203
Polygon -1 true false 215 182 181 192 171 177 169 164 152 142 154 123 170 119 223 163
Line -16777216 false 240 77 162 71
Line -16777216 false 164 71 98 78
Line -16777216 false 96 79 62 105
Line -16777216 false 50 179 88 217
Line -16777216 false 88 217 149 230

fish 3
false
0
Polygon -7500403 true true 137 105 124 83 103 76 77 75 53 104 47 136
Polygon -7500403 true true 226 194 223 229 207 243 178 237 169 203 167 175
Polygon -7500403 true true 137 195 124 217 103 224 77 225 53 196 47 164
Polygon -7500403 true true 40 123 32 109 16 108 0 130 0 151 7 182 23 190 40 179 47 145
Polygon -7500403 true true 45 120 90 105 195 90 275 120 294 152 285 165 293 171 270 195 210 210 150 210 45 180
Circle -1184463 true false 244 128 26
Circle -16777216 true false 248 135 14
Line -16777216 false 48 121 133 96
Line -16777216 false 48 179 133 204
Polygon -7500403 true true 241 106 241 77 217 71 190 75 167 99 182 125
Line -16777216 false 226 102 158 95
Line -16777216 false 171 208 225 205
Polygon -1 true false 252 111 232 103 213 132 210 165 223 193 229 204 247 201 237 170 236 137
Polygon -1 true false 135 98 140 137 135 204 154 210 167 209 170 176 160 156 163 126 171 117 156 96
Polygon -16777216 true false 192 117 171 118 162 126 158 148 160 165 168 175 188 183 211 186 217 185 206 181 172 171 164 156 166 133 174 121
Polygon -1 true false 40 121 46 147 42 163 37 179 56 178 65 159 67 128 59 116

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

shark
false
0
Polygon -7500403 true true 283 153 288 149 271 146 301 145 300 138 247 119 190 107 104 117 54 133 39 134 10 99 9 112 19 142 9 175 10 185 40 158 69 154 64 164 80 161 86 156 132 160 209 164
Polygon -7500403 true true 199 161 152 166 137 164 169 154
Polygon -7500403 true true 188 108 172 83 160 74 156 76 159 97 153 112
Circle -16777216 true false 256 129 12
Line -16777216 false 222 134 222 150
Line -16777216 false 217 134 217 150
Line -16777216 false 212 134 212 150
Polygon -7500403 true true 78 125 62 118 63 130
Polygon -7500403 true true 121 157 105 161 101 156 106 152

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
