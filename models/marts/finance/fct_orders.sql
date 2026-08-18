with

    orders as (
        select * from {{ ref('stg_jaffle_shop__orders') }} 
    ),

    payments as (
        select * from {{ ref('stg_stripe__payments') }}
    ), 


    final as (

        select 
            o.order_id, 
            o.customer_id, 
            sum(p.amount) as amount  
        from orders o left outer join payments p on o.order_id = p.order_id 
        where p.status = 'success'
        group by o.order_id, o.customer_id 

    )

select *
from final
