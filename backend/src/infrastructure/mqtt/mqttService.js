const mqtt = require('mqtt');


// =========================================================
// CONFIGURATION MQTT
// =========================================================

const MQTT_BROKER = 'mqtt://test.mosquitto.org:1883';

const MQTT_TOPIC_DATA = 'calinlink/donnees';
const MQTT_TOPIC_ALERT = 'calinlink/alertes';


// =========================================================
// CLIENT MQTT
// =========================================================

let mqttClient = null;


// =========================================================
// INITIALISATION MQTT
// =========================================================

function initMQTT(io) {

    console.log('');
    console.log('========================================');
    console.log('       CONNEXION MQTT');
    console.log('========================================');

    console.log(
        'Broker :',
        MQTT_BROKER
    );

    console.log(
        'Topic DATA :',
        MQTT_TOPIC_DATA
    );

    console.log(
        'Topic ALERT :',
        MQTT_TOPIC_ALERT
    );


    // =====================================================
    // CONNEXION AU BROKER
    // =====================================================

    mqttClient = mqtt.connect(
        MQTT_BROKER,
        {
            clientId:
                'calinlink-backend-' +
                Date.now(),

            clean: true,

            reconnectPeriod: 5000,

            connectTimeout: 10000
        }
    );


    // =====================================================
    // MQTT CONNECTÉ
    // =====================================================

    mqttClient.on(
        'connect',
        () => {

            console.log('');
            console.log(
                'MQTT Backend connecté !'
            );


            // ==============================================
            // ABONNEMENT AUX TOPICS
            // ==============================================

            mqttClient.subscribe(
                [
                    MQTT_TOPIC_DATA,
                    MQTT_TOPIC_ALERT
                ],
                (error) => {

                    if (error) {

                        console.error(
                            'Erreur abonnement MQTT :',
                            error
                        );

                        return;
                    }


                    console.log(
                        'Abonnement MQTT réussi !'
                    );

                    console.log(
                        'Écoute :',
                        MQTT_TOPIC_DATA
                    );

                    console.log(
                        'Écoute :',
                        MQTT_TOPIC_ALERT
                    );
                }
            );
        }
    );


    // =====================================================
    // MESSAGE MQTT REÇU
    // =====================================================

    mqttClient.on(
        'message',
        (topic, message) => {

            const messageString =
                message.toString();


            console.log('');
            console.log(
                '========================================'
            );

            console.log(
                '         MESSAGE MQTT REÇU'
            );

            console.log(
                '========================================'
            );

            console.log(
                'Topic :',
                topic
            );

            console.log(
                'Message :',
                messageString
            );


            // =================================================
            // DONNÉES CAPTEURS
            // =================================================

            if (
                topic === MQTT_TOPIC_DATA
            ) {

                try {

                    const data =
                        JSON.parse(
                            messageString
                        );


                    console.log(
                        'Données CâlinLink reçues :'
                    );

                    console.log(
                        data
                    );


                    // =========================================
                    // ENVOI VERS SOCKET.IO
                    // =========================================

                    if (io) {

                        io.emit(
                            'calinlink:data',
                            data
                        );


                        console.log(
                            'Données envoyées à Flutter via Socket.IO'
                        );
                    }

                }
                catch (error) {

                    console.error(
                        'Erreur parsing JSON MQTT :',
                        error
                    );
                }
            }


            // =================================================
            // ALERTES
            // =================================================

            else if (
                topic === MQTT_TOPIC_ALERT
            ) {

                const alertData = {

                    message:
                        messageString,

                    timestamp:
                        Date.now()
                };


                console.log(
                    'Alerte CâlinLink :',
                    messageString
                );


                // =========================================
                // ENVOI VERS SOCKET.IO
                // =========================================

                if (io) {

                    io.emit(
                        'calinlink:alert',
                        alertData
                    );


                    console.log(
                        'Alerte envoyée à Flutter via Socket.IO'
                    );
                }
            }
        }
    );


    // =====================================================
    // ERREUR MQTT
    // =====================================================

    mqttClient.on(
        'error',
        (error) => {

            console.error(
                'Erreur MQTT Backend :',
                error
            );
        }
    );


    // =====================================================
    // RECONNEXION
    // =====================================================

    mqttClient.on(
        'reconnect',
        () => {

            console.log(
                'Reconnexion au broker MQTT...'
            );
        }
    );


    // =====================================================
    // OFFLINE
    // =====================================================

    mqttClient.on(
        'offline',
        () => {

            console.log(
                'Backend MQTT hors ligne'
            );
        }
    );


    // =====================================================
    // FERMETURE
    // =====================================================

    mqttClient.on(
        'close',
        () => {

            console.log(
                'Connexion MQTT fermée'
            );
        }
    );


    return mqttClient;
}


function publishMQTT(topic, message) {
    if (mqttClient && mqttClient.connected) {
        mqttClient.publish(topic, message, (err) => {
            if (err) {
                console.error(`Erreur publication MQTT sur ${topic} :`, err);
            } else {
                console.log(`Message MQTT publié sur ${topic} : ${message}`);
            }
        });
    } else {
        console.warn('Impossible de publier sur MQTT : client non connecté');
    }
}


// =========================================================
// EXPORT
// =========================================================

module.exports = {
    initMQTT,
    publishMQTT
};