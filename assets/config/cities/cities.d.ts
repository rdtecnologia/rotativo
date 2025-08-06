import env from '../env/env.json';

export enum ShowByCredits {
  CREDITS = 'credits',
  REAL = 'real',
}

type Balance = {
  showBy: string;
  showDetails: boolean;
};

type PurchaseProducts = {
  credits: number;
  price: number;
};

type Purchase = {
  vehicleTypeDefault?: number;
  showBy: string;
  chargeback: boolean;
  minCreditsByVehicle: {[vehicleType: string]: number};
  products: {[vehicleType: string]: PurchaseProducts[]};
  payment: {creditCard: boolean; billet: boolean; pix?: boolean};
};

type ParkingTime = {
  time: number;
  price: number;
  credits: number;
};

type ParkingRules = {[vehicleType: string]: ParkingTime[]};

type FAQ = {
  title: string;
  content: string;
};

export type CityConfig = {
  city: string;
  domain: string;
  latitude: number;
  longitude: number;
  downloadLink: string;
  termsLink: string;
  androidPackage: string;
  iosPackage: string;
  whatsapp?: string;
  chatBotURL?: string;
  products: number[];
  vehicleTypes: number[];
  mainLogo: string;
  logoMenu: string;
  balance: Balance;
  parkingRules: ParkingRules;
  parkingRulesText?: string;
  purchase: Purchase;
  faq: FAQ[];
};

export type Envorioment = typeof env.dev;

declare module 'ConselheiroLafaiete.json' {
  export interface DefaultCityConfig extends CityConfig {}
}
