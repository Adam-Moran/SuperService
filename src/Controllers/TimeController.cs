using System;
using Microsoft.AspNetCore.Mvc;

namespace SuperService.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TimeController : ControllerBase
    {
        private readonly IClock mClock;

        public TimeController(IClock clock) => mClock = clock;

        [HttpGet]
        public DateTime Get() => mClock.GetNow();
    }
}
