/**
 *
 * @description A sample webservice to create Cases in Salesforce
 * 
 * endpoint : /services/apexrest/customer/case
 * sample request body :
  {
    "subject"     : "Sprinklr-DH Social Case",
    "description" : "Hello Talabat, the food is awesome"
  }
 */
@RestResource(urlMapping='/customer/case/*')
global with sharing class SampleCaseService {
  /**
   * @description Custom exception for this service
   */
  class SampleCaseServiceException extends Exception {
    public Integer statusCode = 400;

    /**
     * @description Constructor for the SampleCaseServiceException
     * @param message - standard Exception message
     * @param statusCode - HTTP statuscode, returned by the Webservice
     */
    public SampleCaseServiceException(String message, Integer statusCode) {
      this.setMessage(message);
      this.statusCode = statusCode;
    }
  }

  private Map<String, Object> propMap;
  private Case caseCreated;

  /**
   * @description The class which processes the requet
   * @param requestBody - body of the HTTP request
   */
  public SampleCaseService(String requestBody) {
    try {
      this.propMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
    } catch (Exception e) {
      throw new SampleCaseServiceException('Wrong request format', 400);
    }
  }

  /**
   * @description Creates the case (execution)
   */
  public void createCase() {
    try {
      this.caseCreated = new Case();
      for (String fieldName : this.propMap.keySet()) {
        this.caseCreated.put(fieldName, this.propMap.get(fieldName));
      }
      insert this.caseCreated;
    } catch (Exception e) {
      if (e instanceof SampleCaseServiceException)
        throw e;
      throw new SampleCaseServiceException(e.getMessage(), 500);
    }
  }

  /**
   * @description returns id of the newly created case
   */
  public Id getCaseId() {
    if (this.caseCreated != null) {
      return this.caseCreated.Id;
    }
    return null;
  }
  /**
   * @description class represents response
   */
  public class SampleCaseServiceResponse {
    public Boolean success;
    public String message;
    public Id caseId;
  }

  @HttpPost
  /**
   * @description HTTP binding
   */
  global static void onPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    SampleCaseServiceResponse serviceResponse = new SampleCaseServiceResponse();
    try {
      SampleCaseService caseService;
      caseService = new SampleCaseService(req.requestBody.toString());
      caseService.createCase();
      res.statusCode = 201;
      serviceResponse.success = true;
      serviceResponse.caseId = caseService.getCaseId();
    } catch (SampleCaseServiceException e) {
      res.statusCode = e.statusCode;
      serviceResponse.success = false;
      serviceResponse.message = e.getMessage();
    }
    res.responseBody = Blob.valueOf(JSON.serialize(serviceResponse));
  }
}
