/*De quantos em quantos dias, em média, as pessoas compram? Use a mediana como média.*/

/*Ordenei as comprar por data buscando recuperar qual a próxima compra do cliente, busquei a diferença de dias entre a 
  compra e a próxima comprar, desconsiderando as compras do mesmo dia, tendo a diferença de dias, calculei a medianas e média dos dias entre compras */

SELECT name,
       median                     mediana_dias_compra,
       round(AVG(days_NXT_BUY),2) media_dias_compra
FROM (
SELECT BAS.ID,customer.name,
       PERCENTILE_CONT(days_NXT_BUY, 0.5 RESPECT NULLS) OVER(PARTITION BY BAS.ID) AS median,
       days_NXT_BUY

FROM ( SELECT BAS.ID,BAS.DATE,     
                DATE_DIFF(DATE_NXT_BUY,BAS.DATE, DAY) as days_NXT_BUY

        FROM (select *,CAST(timestamp AS DATE) DATE, RANK() OVER   
                  (PARTITION BY id ORDER BY timestamp ASC) AS NUM_BUY 
              from `dito-data-scientist-challenge.tracking.dito`
              WHERE type = 'track'
               AND properties.action = 'buy') BAS
        LEFT JOIN (select CAST(timestamp AS DATE) DATE_NXT_BUY , id , RANK() OVER   
                  (PARTITION BY id ORDER BY timestamp ASC)  AS NXT_BUY 
              from `dito-data-scientist-challenge.tracking.dito`
                    WHERE type = 'track'
               AND properties.action = 'buy') NXT_BUY ON NXT_BUY.ID = BAS.ID and NXT_BUY.NXT_BUY = BAS.NUM_BUY +1

         WHERE BAS.type = 'track'
         AND BAS.properties.action = 'buy') BAS
INNER JOIN (SELECT EXT.traits.name , 
                     EXT.traits.email ,
                     EXT.traits.phone ,
                     EXT.id
              FROM `dito-data-scientist-challenge.tracking.dito` EXT
              WHERE EXISTS (SELECT 1 FROM (
                                          SELECT id, max(timestamp) max_timestamp
                                          FROM `dito-data-scientist-challenge.tracking.dito`
                                          WHERE type = 'identify'
                                          group by id) INT
                             WHERE INT.id = EXT.id  and  INT.max_timestamp = EXT.timestamp) ) customer    ON  customer.ID = BAS.ID     
         
         
 
WHERE BAS.days_NXT_BUY <> 0)
GROUP BY name,median
order by 1;