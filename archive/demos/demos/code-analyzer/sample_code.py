# Sample code for analysis
import requests
import json
from datetime import datetime

class DataProcessor:
    def __init__(self, api_key):
        self.api_key = api_key
        self.session = requests.Session()
    
    def fetch_data(self, endpoint):
        """Fetch data from API endpoint"""
        response = self.session.get(endpoint, headers={'Authorization': f'Bearer {self.api_key}'})
        return response.json()
    
    def process_data(self, data):
        """Process raw data"""
        processed = []
        for item in data:
            if item.get('active'):
                processed.append({
                    'id': item['id'],
                    'name': item['name'],
                    'timestamp': datetime.now().isoformat()
                })
        return processed
    
    def save_results(self, results, filename='output.json'):
        """Save processed results to file"""
        with open(filename, 'w') as f:
            json.dump(results, f, indent=2)

def calculate_metrics(data):
    """Calculate basic metrics from data"""
    total = len(data)
    active = sum(1 for item in data if item.get('active'))
    return {
        'total': total,
        'active': active,
        'inactive': total - active
    }