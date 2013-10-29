Travaux pratiques de confiance électronique
===========================================

Ce document a pour but d'illustrer les grands concepts de la confiance
électronique (cryptographie, certificats, signature électronique etc.), principalement par la
manipulation d'outils en ligne de commande.

Les chapitres 1 à 3 introduisent les primitives cryptographiques utilisées dans le domaine de la
confiance électronique : algorithmes de chiffrement symétrique, algorithmes de hachage, et cryptographie
asymétrique (bi-clés RSA, chiffrement et signature).

Ensuite, les chapitres 4 et 5 s'intéressent aux structures de données de base d'une infrastructure
de gestion de clés (IGC, ou PKI pour *Public Key Infrastructure*, ou encore ICP pour infrastructure à
clés publiques) : les certificats électroniques X.509 et les listes de certificats révoqués.

Les usages de la confiance électronique font l'objet des chapitres 6 à 10 : protection de la confidentialité
des données à l'aide des formats PKCS#7/CMS et XML Encryption, signature électronique en
utilisant les formats PKCS#7/CMS et XML Signature, authentification web par certificat.

Le chapitre 11 sur l'horodatage prépare enfin les chapitres 12 et 13 sur la signature électronique
avancée avec les formats CAdES et XAdES.

## Ressources complémentaires ##

Le code source, les fichiers générés et le code source de ce livre sont publiés sur [GitHub](https://github.com/spujadas/tp-confiance).

## Licence ##

Le texte de ce document est disponible sous licence [Creative Commons paternité partage à l’identique](http://creativecommons.org/licenses/by-sa/3.0/deed.fr), à l'exception des éléments suivants, soumis à des conditions d'utilisation spécifiques non compatibles avec cette licence :

- Les captures d'écran des produits Microsoft sont utilisées avec l'autorisation de Microsoft.

- Les extraits de documents normatifs sont cités conformément à l'article 10.1 de la convention de
Berne.

- L'utilisation de code source dérivé du code source d'OpenSSL est soumis à des exigences particulières.

Se reporter à l'annexe G.1 du livre pour plus d'informations.

## À propos ##

Ce livre a été rédigé par Sébastien Pujadas. Son profil professionnel complet est publié sur [LinkedIn](http://www.linkedin.com/in/spujadas).