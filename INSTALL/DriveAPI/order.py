# {
#     "id": 6619011,
#     "order_source_order_id": "111-4278719-2814625",
#     "order_source_name": "Amazon",
#     "order_shipping_promise_date": "2024-09-25 23:59:59.0",
#     "payment_status": "Charged",
#     "sellercloud_order_status": "Complete",
#     "instructions": "CLOSED AFTER 4PM. For after hours delivery please use 9 Mulford court Bridgeton, 3/4 mile south of the store.  Thank you!",
#     "items": [
#         {
#             "chassis_id": "1552378-3",
#             "order_item_id": 1552378,
#             "product_id": "STD 100215",
#             "kit_item_id": 1912012,
#             "kit_product_id": "DSB B07V4GX7ZL",
#             "product_type": "Workstation",
#             "description": "Dell T5810 Workstation",
#             "purchase_group": "T5810 1X HS",
#             "product_line": "Precision",
#             "model_number": "T5810"
#         },
#         {
#             "chassis_id": "1552378-2",
#             "order_item_id": 1552378,
#             "product_id": "STD 100215",
#             "kit_item_id": 1912012,
#             "kit_product_id": "DSB B07V4GX7ZL",
#             "product_type": "Workstation",
#             "description": "Dell T5810 Workstation",
#             "purchase_group": "T5810 1X HS",
#             "product_line": "Precision",
#             "model_number": "T5810"
#         },
#         {
#             "chassis_id": "1552378-1",
#             "order_item_id": 1552378,
#             "product_id": "STD 100215",
#             "kit_item_id": 1912012,
#             "kit_product_id": "DSB B07V4GX7ZL",
#             "product_type": "Workstation",
#             "description": "Dell T5810 Workstation",
#             "purchase_group": "T5810 1X HS",
#             "product_line": "Precision",
#             "model_number": "T5810"
#         },
#         {
#             "chassis_id": "1552378-4",
#             "order_item_id": 1552378,
#             "product_id": "STD 100215",
#             "kit_item_id": 1912012,
#             "kit_product_id": "DSB B07V4GX7ZL",
#             "product_type": "Workstation",
#             "description": "Dell T5810 Workstation",
#             "purchase_group": "T5810 1X HS",
#             "product_line": "Precision",
#             "model_number": "T5810"
#         }
#     ]
# }
class Item:
    def __init__(self, chassis_id: str, order_item_id: int, product_id: str, kit_item_id: int, kit_product_id: str, product_type: str, description: str, purchase_group: str, product_line: str, model_number: str):
        self.chassis_id = chassis_id
        self.order_item_id = order_item_id
        self.product_id = product_id
        self.kit_item_id = kit_item_id
        self.kit_product_id = kit_product_id
        self.product_type = product_type
        self.description = description
        self.purchase_group = purchase_group
        self.product_line = product_line
        self.model_number = model_number
        self.serial_number = None
        self.checklist_id = None

    def set_serial_number(self, serial_number: str):
        self.serial_number = serial_number

    def __str__(self):
        return f'Item {self.chassis_id} \
            \n {self.order_item_id} \
            \n {self.product_id} \
            \n {self.kit_item_id} \
            \n {self.kit_product_id} \
            \n {self.product_type} \
            \n {self.description} \
            \n {self.purchase_group} \
            \n {self.product_line} \
            \n {self.model_number} \
            \n {self.serial_number} \
            \n {self.checklist_id}'
    

class Order:
    def __init__(self, order_data):
        self.id = order_data.get("id")
        self.order_source_order_id = order_data.get("order_source_order_id")
        self.order_source_name = order_data.get("order_source_name")
        self.order_shipping_promise_date = order_data.get("order_shipping_promise_date")
        self.payment_status = order_data.get("payment_status")
        self.sellercloud_order_status = order_data.get("sellercloud_order_status")
        self.instructions = order_data.get("instructions")
        self.items = [OrderItem(item_data) for item_data in order_data.get("items", [])]

    def get_items(self):
        return self.items


    def to_json(self):
        return {
            "id": self.id,
            "order_source_order_id": self.order_source_order_id,
            "order_source_name": self.order_source_name,
            "order_shipping_promise_date": self.order_shipping_promise_date,
            "payment_status": self.payment_status,
            "sellercloud_order_status": self.sellercloud_order_status,
            "instructions": self.instructions,
            "items": [item.to_dict() for item in self.items]
        }

    
    def __repr__(self):
        return f"<Order(id={self.id}, source={self.order_source_name}, items_count={len(self.items)})>"
    
    def get_item_by_chassis_id(self, chassis_id: str) -> Item:
        for item in self.items:
            if item.chassis_id == chassis_id:
                return item
        return None
    
    def get_item_by_serial_number(self, serial_number: str) -> Item:
        for item in self.items:
            if item.serial_number == serial_number:
                return item
        return None

    def _update_item(self, item: Item):
        for i in range(len(self.items)):
            if self.items[i].chassis_id == item.chassis_id:
                self.items[i] = item
                return
    
    def set_chassis_serial(self, chassis_id: str, serial_number: str):
        item = self.get_item_by_chassis_id(chassis_id)
        if item:
            item.set_serial_number(serial_number)
            self._update_item(item)
    
    def __str__(self):
        return f'Order {self.id} \n {self.order_source_name} \n {self.order_source_order_id} \n {self.order_shipping_promise_date} \n {self.payment_status} \n {self.sellercloud_order_status} \n {self.instructions}'



# I WOULD PUT THESE IN A HELPER FILE
def _map_json_to_order(json: dict) -> Order:
    items = []
    for item in json['items']:
        items.append(Item(
            item['chassis_id'],
            item['order_item_id'],
            item['product_id'],
            item['kit_item_id'],
            item['kit_product_id'],
            item['product_type'],
            item['description'],
            item['purchase_group'],
            item['product_line'],
            item['model_number']
        ))
    return Order(
        json['id'],
        json['order_source_order_id'],
        json['order_source_name'],
        json['order_shipping_promise_date'],
        json['payment_status'],
        json['sellercloud_order_status'],
        json['instructions'],
        items
    )
def _map_order_to_json(order: Order) -> dict:
    items = []
    for item in order.items:
        items.append({
            'chassis_id': item.chassis_id,
            'order_item_id': item.order_item_id,
            'product_id': item.product_id,
            'kit_item_id': item.kit_item_id,
            'kit_product_id': item.kit_product_id,
            'product_type': item.product_type,
            'description': item.description,
            'purchase_group': item.purchase_group,
            'product_line': item.product_line,
            'model_number': item.model_number
        })
    return {
        'id': order.id,
        'order_source_order_id': order.order_source_order_id,
        'order_source_name': order.order_source_name,
        'order_shipping_promise_date': order.order_shipping_promise_date,
        'payment_status': order.payment_status,
        'sellercloud_order_status': order.sellercloud_order_status,
        'instructions': order.instructions,
        'items': items
    }

import requests



def get_order_from_api(order_id: int, token: str) -> Order:
    url = f'http://192.168.1.153:1036/qc/{order_id}'
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return _map_json_to_order(response.json())
    return None

    

def get_api_token() -> str:
    url = 'http://192.168.1.153:1036/auth/login'
    username = 'hlee'
    password = 'tempPassword'
    response = requests.post(url, json={'username': username, 'password': password})
    if response.status_code == 200:
        return response.json()['token']
    return None

# api_token = get_api_token()
# order: Order = get_order_from_api(6619011, api_token)


# print(order)

# for item in order.items:
#     print(item)

# order.set_chassis_serial('1552378-3', '12300-AAAA-00')
# order.set_chassis_serial('1552378-2', '12300-BBBB-01')
# order.set_chassis_serial('1552378-1', '12300-CCCC-02')
# order.set_chassis_serial('1552378-4', '12300-DDDD-03')

# for item in order.items:
#     print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
#     print(item)