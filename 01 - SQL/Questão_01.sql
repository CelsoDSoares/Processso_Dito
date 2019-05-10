/*1. Qual o nome, email e telefone das 5 pessoas que mais geraram receita?*/

/*Recuperei os dados dos clientes, levando em consideração o último email e telefone,
  depois busquei a informação dos 5 clientes que realização mais compras.*/


SELECT customer.name,
       customer.email,
       customer.phone,
       deal.revenue

FROM (
SELECT customer.name,
       IFNULL(customer.email, last_email.last_email) email,
       IFNULL(customer.phone, last_phone.last_phone) phone,
       customer.id

FROM (
SELECT EXT.traits.name , 
       EXT.traits.email ,
       EXT.traits.phone ,
       EXT.id
FROM `dito-data-scientist-challenge.tracking.dito` EXT
WHERE EXISTS (SELECT 1 FROM (
                            SELECT id, max(timestamp) max_timestamp
                            FROM `dito-data-scientist-challenge.tracking.dito`
                            WHERE type = 'identify'
                            group by id) INT
               WHERE INT.id = EXT.id  and  INT.max_timestamp = EXT.timestamp) ) customer
left join ( SELECT  EXT.id,
                    EXT.traits.email last_email
FROM `dito-data-scientist-challenge.tracking.dito` EXT
WHERE EXISTS (SELECT 1 FROM (SELECT id, max(timestamp) max_timestamp
                            FROM `dito-data-scientist-challenge.tracking.dito`
                            WHERE type = 'identify'
                            and traits.email is not null
                            group by id) INT
               WHERE INT.id = EXT.id  and  INT.max_timestamp = EXT.timestamp) )   last_email   on   last_email.id    = customer.id  
 
left join ( SELECT  EXT.id,
                    EXT.traits.phone last_phone
FROM `dito-data-scientist-challenge.tracking.dito` EXT
WHERE EXISTS (SELECT 1 FROM (SELECT id, max(timestamp) max_timestamp
                            FROM `dito-data-scientist-challenge.tracking.dito`
                            WHERE type = 'identify'
                            and traits.phone is not null
                            group by id) INT
               WHERE INT.id = EXT.id  and  INT.max_timestamp = EXT.timestamp) )   last_phone  on   last_phone.id    = customer.id  ) customer
INNER JOIN (SELECT id,revenue, RANK() OVER ( ORDER BY revenue DESC ) AS RANK_NUM
            FROM (
            SELECT id,
                   round(SUM(properties.revenue),5) revenue
            FROM `dito-data-scientist-challenge.tracking.dito`
            WHERE type = 'track'
             AND properties.action = 'buy'
             group by ID)) deal ON deal.id = customer.id
WHERE RANK_NUM <= 5 
 ORDER BY deal.revenue DESC