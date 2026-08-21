with
    customers as (

        select * from {{ ref('stg_jaffle_shop__customers') }}  

    ),

    orders as (

        select * from {{ ref('stg_jaffle_shop__orders') }} 

    ),

    payments as (
        select * from {{ ref('stg_stripe__payments') }}
    ),

    customer_orders as (

        select
            o.customer_id,

            min(o.order_date) as first_order_date,
            max(o.order_date) as most_recent_order_date,
            count(o.order_id) as number_of_orders, 
            sum(p.amount) as total_spent 

        from orders o left outer join payments p on o.order_id = p.order_id 

        group by 1

    ),

    final as (

        select
            customers.customer_id,
            customers.first_name,
            customers.last_name,
            customer_orders.first_order_date,
            customer_orders.most_recent_order_date,
            coalesce(customer_orders.number_of_orders, 0) as number_of_orders, 
            coalesce(customer_orders.total_spent, 0) as lifetime_value 

        from customers

        left join customer_orders using (customer_id)

    )

select *
from final
