import json
import boto3 # SDK da AWS para conectar com o SQS

# Inicializa o cliente SQS fora do handler para performance
sqs = boto3.client('sqs')

# TODO: Substitua pelo URL da sua fila após criá-la no console SQS
QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/317236425577/OrdersQueue'

def lambda_handler(event, context):
    try:
        # Pega o corpo da requisição
        body_str = event.get('body', '{}')
        body = json.loads(body_str)
        
        # Sua validação que já funciona
        if not body.get('cliente_id') or not body.get('valor'):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Dados incompletos'})
            }

        # --- NOVIDADE DA SPRINT 2: Envio para o SQS ---
        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=body_str # Enviamos a string original do JSON
        )
        # ----------------------------------------------

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Pedido enviado para processamento!', 
                'protocolo': body.get('cliente_id')
            })
        }
    except Exception as e:
        return {
            'statusCode': 500, 
            'body': json.dumps({'error': str(e)})
        }

        {

}