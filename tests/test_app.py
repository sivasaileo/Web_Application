import pytest
from app.app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home(client):
    rv = client.get('/')
    assert rv.status_code == 200
    assert b"Hello, This is Siva sai. Welcome!" in rv.data

def test_about(client):
    rv = client.get('/about')
    assert rv.status_code == 404  # Since the about route is not defined in the app