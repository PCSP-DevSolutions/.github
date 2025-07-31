import requests
from order import Order, Item

class API:
    def __init__(self, username, password):
        self.base_url = 'http://192.168.1.153:1036/'
        self.token = self._get_token(username, password)
        self.headers = {'Authorization': f'Bearer {self.token}'}

    def _get_token(self, username, password):
        url = self.base_url + 'auth/login'
        response = requests.post(url, json={'username': username, 'password': password})
        if response.status_code == 200:
            return response.json()['token']
        return None
    
    def _get(self, url):
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            return response.json()
        return None
    
    def get_order(self, order_id: int):
        url = self.base_url + f'qc/{order_id}'
        return self._map_json_to_order(self._get(url))
    
    def get_status_and_instructions(self, order_id: int) -> tuple:
        url = self.base_url + f'qc/{order_id}'
        response = self._get(url)
        if not response: return None
        return response['sellercloud_order_status'], response['instructions']
    
    # I WOULD PUT THESE IN A HELPER FILE
    def _map_json_to_order(self, json: dict) -> Order:
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
    def _map_order_to_json(self, order: Order) -> dict:
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


