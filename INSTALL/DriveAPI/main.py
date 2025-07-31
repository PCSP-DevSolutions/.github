
from api import API
from order import Order, Item

if __name__ == '__main__':
    user = 'hlee'
    password = 'tempPassword'
    api = API(user, password)
    order_num = 6619011

    order = database.get_order(order_num)

    order = api.get_order(6619011)

    print(order)
    
    for item in order.items:
        print(item)

    order.set_chassis_serial('1552378-3', '12300-AAAA-00')
    order.set_chassis_serial('1552378-4', '12300-BBBB-00')
    order.set_chassis_serial('1552378-1', '12300-CCCC-00')

    
    order.save()
